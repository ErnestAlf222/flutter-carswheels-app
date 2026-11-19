import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';
import 'package:cars_wheels_app/features/search/presentation/cubits/search_state.dart';

/// Búsqueda de marcas y modelos: consulta con debounce, índice bajo demanda y recientes.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required this.contextSource,
    required this.buildIndex,
    required this.searchCatalog,
    required this.getBrandGroups,
    required this.getTopBrands,
    required this.addRecent,
    required this.getRecents,
    required this.removeRecent,
    required this.clearRecents,
    this.debounce = const Duration(
      milliseconds: SearchConfig.debounceMilliseconds,
    ),
  }) : super(SearchState(scope: contextSource.scope)) {
    _scopeSubscription = contextSource.scopeChanges.listen(_onScopeChanged);
  }

  final SearchContextSource contextSource;
  final BuildSearchIndexUseCase buildIndex;
  final SearchCatalogUseCase searchCatalog;
  final GetBrandGroupsUseCase getBrandGroups;
  final GetTopBrandsUseCase getTopBrands;
  final AddRecentSearchUseCase addRecent;
  final GetRecentSearchesUseCase getRecents;
  final RemoveRecentSearchUseCase removeRecent;
  final ClearRecentSearchesUseCase clearRecents;

  /// Espera tras la última tecla antes de buscar.
  final Duration debounce;

  // Recursos cancelables: se reasignan al reiniciar.
  Timer? _debounceTimer;
  StreamSubscription<SearchScopeEntity?>? _scopeSubscription;
  StreamSubscription<SearchIndexStatusEntity>? _indexSubscription;

  // Verdadero desde que alguien pidió el índice; antes no se construye nada.
  bool _indexWanted = false;

  // Hay un pedido de foco sin atender.
  bool _focusPending = false;

  /// Pide el índice del alcance vigente (al entrar a la pantalla de búsqueda).
  void ensureIndex() {
    _indexWanted = true;
    unawaited(loadRecents());
    final scope = state.scope;
    if (scope == null || _indexSubscription != null) return;
    if (state.indexStatus == null) _startBuild(scope);
  }

  /// Reintenta: todo el índice si falló, o solo las marcas fallidas si quedó parcial.
  void retryIndex() {
    _indexWanted = true;
    final scope = state.scope;
    if (scope == null) return;
    _startBuild(scope, retryFailedOnly: state.isPartial);
  }

  /// Pide que el campo de búsqueda se enfoque al mostrarse.
  void requestFocus() {
    _focusPending = true;
    emit(state.copyWith(focusRequestId: state.focusRequestId + 1));
  }

  /// Verdadero una sola vez por cada pedido de foco; quien lo atiende lo consume.
  bool takeFocusRequest() {
    final pending = _focusPending;
    _focusPending = false;
    return pending;
  }

  /// Lee las búsquedas recientes guardadas.
  Future<void> loadRecents() async {
    try {
      final recents = await getRecents();
      if (!isClosed) emit(state.copyWith(recents: recents));
    } on Object {
      // Sin recientes legibles la pantalla sigue funcionando.
    }
  }

  /// Cambia el texto; busca tras el debounce, o vacía los resultados si no llega al mínimo.
  void onQueryChanged(String text) {
    _debounceTimer?.cancel();
    final meetsMinimum =
        TextNormalizer.normalize(text).length >= SearchConfig.minQueryLength;
    emit(
      state.copyWith(
        query: text,
        clearBrandFilter: true,
        results: meetsMinimum ? null : const [],
      ),
    );
    if (meetsMinimum) _debounceTimer = Timer(debounce, _applySearch);
  }

  /// Vacía el campo y los resultados.
  void clearQuery() {
    _debounceTimer?.cancel();
    emit(state.copyWith(query: '', clearBrandFilter: true, results: const []));
  }

  /// Acción de teclado: busca ya y guarda la consulta como reciente.
  Future<void> submit() async {
    _debounceTimer?.cancel();
    _applySearch();
    await _saveRecent(state.query);
  }

  /// Toque en un resultado: guarda la consulta como reciente.
  Future<void> registerResultTap() => _saveRecent(state.query);

  /// Muestra los grupos de una marca en la misma lista, sin navegar.
  void selectBrand(String brand) {
    _debounceTimer?.cancel();
    emit(state.copyWith(query: brand, brandFilter: brand));
    _applySearch();
  }

  /// Repite una búsqueda reciente.
  Future<void> useRecent(RecentSearchEntity recent) async {
    _debounceTimer?.cancel();
    emit(state.copyWith(query: recent.text, clearBrandFilter: true));
    _applySearch();
    await _saveRecent(recent.text);
  }

  /// Borra una búsqueda reciente.
  Future<void> removeRecentSearch(String key) async {
    try {
      await removeRecent(key);
    } on Object {
      // Si no se pudo borrar, la lista se relee tal como quedó.
    }
    await loadRecents();
  }

  /// Borra todas las búsquedas recientes.
  Future<void> clearRecentSearches() async {
    try {
      await clearRecents();
    } on Object {
      // Si no se pudo borrar, la lista se relee tal como quedó.
    }
    await loadRecents();
  }

  Future<void> _saveRecent(String text) async {
    try {
      if (await addRecent(text)) await loadRecents();
    } on Object {
      // Perder una reciente no debe romper la búsqueda.
    }
  }

  // Calcula resultados y accesos rápidos con el índice que haya.
  void _applySearch() {
    if (isClosed) return;
    final scope = state.scope;
    final brand = state.brandFilter;
    final List<SearchResultEntity> results;
    if (scope == null) {
      results = const [];
    } else if (brand != null) {
      results = getBrandGroups(scope, brand);
    } else {
      results = searchCatalog(scope, state.query);
    }
    emit(
      state.copyWith(
        results: results,
        quickBrands: scope == null
            ? const []
            : getTopBrands(scope, SearchConfig.quickBrandCount),
      ),
    );
  }

  // Otro mercado o año: cancela, descarta lo del alcance anterior y reconstruye.
  void _onScopeChanged(SearchScopeEntity? scope) {
    if (scope == state.scope) return;
    _cancelBuild();
    emit(
      state.copyWith(
        scope: scope,
        clearScope: scope == null,
        clearIndexStatus: true,
        indexFailed: false,
        results: const [],
        quickBrands: const [],
      ),
    );
    if (scope != null && _indexWanted) _startBuild(scope);
  }

  void _cancelBuild() {
    unawaited(_indexSubscription?.cancel());
    _indexSubscription = null;
    buildIndex.cancel();
  }

  void _startBuild(SearchScopeEntity scope, {bool retryFailedOnly = false}) {
    unawaited(_indexSubscription?.cancel());
    emit(state.copyWith(indexFailed: false));
    final subscription = buildIndex(scope, retryFailedOnly: retryFailedOnly)
        .listen(
          (status) {
            if (isClosed || state.scope != scope) return;
            emit(state.copyWith(indexStatus: status));
            // Con cada avance se repite la consulta vigente.
            _applySearch();
          },
          onError: (Object _) {
            if (isClosed || state.scope != scope) return;
            emit(state.copyWith(indexFailed: true));
          },
        );
    subscription.onDone(() {
      if (identical(_indexSubscription, subscription)) {
        _indexSubscription = null;
      }
    });
    _indexSubscription = subscription;
  }

  @override
  Future<void> close() async {
    _debounceTimer?.cancel();
    await _scopeSubscription?.cancel();
    await _indexSubscription?.cancel();
    buildIndex.cancel();
    await contextSource.close();
    return super.close();
  }
}
