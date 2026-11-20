import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';
import 'package:cars_wheels_app/features/search/presentation/cubits/search_analysis_runner.dart';
import 'package:cars_wheels_app/features/search/presentation/cubits/search_state.dart';

/// Buscador de marcas y modelos: búsqueda global con alcance suave de marca,
/// sugerencias, otros años, índice bajo demanda y recientes.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required this.contextSource,
    required this.buildIndex,
    required this.searchWithScope,
    required this.suggestTerms,
    required this.searchOtherYears,
    required this.getBrandGroups,
    required this.getIndexBrands,
    required this.addRecent,
    required this.getRecents,
    required this.removeRecent,
    required this.clearRecents,
    required this.analysisRunner,
    required this.filterService,
    this.debounce = const Duration(
      milliseconds: SearchConfig.debounceMilliseconds,
    ),
  }) : super(SearchState(scope: contextSource.scope)) {
    _scopeSubscription = contextSource.scopeChanges.listen(_onScopeChanged);
  }

  final SearchContextSource contextSource;
  final BuildSearchIndexUseCase buildIndex;
  final SearchWithScopeUseCase searchWithScope;
  final SuggestSearchTermsUseCase suggestTerms;
  final SearchOtherYearsUseCase searchOtherYears;
  final GetBrandGroupsUseCase getBrandGroups;
  final GetIndexBrandsUseCase getIndexBrands;
  final AddRecentSearchUseCase addRecent;
  final GetRecentSearchesUseCase getRecents;
  final RemoveRecentSearchUseCase removeRecent;
  final ClearRecentSearchesUseCase clearRecents;
  final SearchAnalysisRunner analysisRunner;

  /// Cuenta opciones y aplica filtros y orden; lo usa también la pantalla.
  final SearchFilterService filterService;

  /// Espera tras la última tecla antes de buscar.
  final Duration debounce;

  // Recursos cancelables: se reasignan al reiniciar.
  Timer? _debounceTimer;
  StreamSubscription<SearchScopeEntity?>? _scopeSubscription;
  StreamSubscription<SearchIndexStatusEntity>? _indexSubscription;
  StreamSubscription<SearchOtherYearsStatusEntity>? _otherYearsSubscription;
  StreamSubscription<SearchTraitsUpdate>? _analysisSubscription;

  // Agrupa los avances del índice antes de repetir la consulta vigente.
  Timer? _indexRerunTimer;

  // Reintento automático con retroceso del índice parcial o fallido.
  Timer? _indexRetryTimer;
  int _indexRetryAttempts = 0;

  // La hoja de filtros está abierta: el análisis corre aunque no haya filtros.
  bool _filtersSheetOpen = false;

  // Llegaron resultados nuevos mientras corría un análisis.
  bool _analysisRerun = false;

  // Verdadero desde que alguien pidió el índice; antes no se construye nada.
  bool _indexWanted = false;

  // Hay un pedido de foco sin atender.
  bool _focusPending = false;

  // Sugerencias "para ti" de la visita: se calculan una vez y se conservan.
  String? _picksKey;
  List<SearchResultEntity> _picks = const [];

  /// Modelos al azar del alcance vigente para el campo vacío.
  ///
  /// Salen del índice ya construido, sin red. Con la misma [seed] y el mismo
  /// alcance se conservan, aunque el índice siga creciendo; otro mercado, otro
  /// año u otra semilla las recalculan. Vacío mientras no haya datos.
  List<SearchResultEntity> picksFor(int seed) {
    final scope = state.scope;
    if (scope == null) return const [];
    final key = '${scope.key} $seed';
    if (key == _picksKey && _picks.isNotEmpty) return _picks;
    _picksKey = key;
    return _picks = searchWithScope.picks(scope, seed: seed);
  }

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
    // Un reintento manual cancela la espera automática y la reinicia.
    _indexRetryTimer?.cancel();
    _indexRetryAttempts = 0;
    _startBuild(scope, retryFailedOnly: state.isPartial);
  }

  /// Al volver la conexión: repite una vez el índice que falló o quedó parcial.
  void restoreAfterReconnect() {
    final scope = state.scope;
    if (!_indexWanted || scope == null) return;
    if (state.indexFailed || state.isPartial) {
      retryIndex();
    } else if (state.indexStatus == null && _indexSubscription == null) {
      _startBuild(scope);
    }
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

  /// Cambia el texto; busca tras el debounce. Con alcance de marca y sin texto
  /// suficiente muestra de inmediato los modelos de la marca.
  void onQueryChanged(String text) {
    _debounceTimer?.cancel();
    _cancelOtherYears();
    _cancelAnalysis();
    final meetsMinimum =
        TextNormalizer.normalize(text).length >= SearchConfig.minQueryLength;
    emit(
      state.copyWith(
        query: text,
        clearOtherYears: true,
        otherYearsFailed: false,
        results: meetsMinimum || state.scopeBrand != null ? null : const [],
        otherResults: meetsMinimum ? null : const [],
        brandMatches: meetsMinimum ? null : const [],
        suggestions: const [],
        // Con texto suficiente, el vacío espera a que la búsqueda termine y se calme.
        isSearching: meetsMinimum,
      ),
    );
    if (meetsMinimum) {
      _debounceTimer = Timer(debounce, () {
        _debounceTimer = null;
        _applySearch();
      });
    } else if (state.scopeBrand != null) {
      _applySearch();
    }
  }

  /// Vacía el campo; el alcance de marca se conserva.
  void clearQuery() {
    _debounceTimer?.cancel();
    _cancelOtherYears();
    _cancelAnalysis();
    emit(
      state.copyWith(
        query: '',
        results: const [],
        otherResults: const [],
        brandMatches: const [],
        suggestions: const [],
        searchedText: '',
        isSearching: false,
        clearOtherYears: true,
        otherYearsFailed: false,
      ),
    );
    if (state.scopeBrand != null) _applySearch();
  }

  /// Acción de teclado: busca ya y guarda la consulta como reciente.
  Future<void> submit() async {
    _debounceTimer?.cancel();
    _applySearch();
    await _saveRecent(state.query);
  }

  /// Toque en un resultado: guarda la consulta como reciente.
  Future<void> registerResultTap() => _saveRecent(state.query);

  /// Fija una marca como alcance suave y limpia el texto: lista sus modelos.
  void selectBrand(String brand) {
    _debounceTimer?.cancel();
    _cancelOtherYears();
    _cancelAnalysis();
    emit(
      state.copyWith(
        scopeBrand: brand,
        query: '',
        clearOtherYears: true,
        otherYearsFailed: false,
        otherResults: const [],
        brandMatches: const [],
        suggestions: const [],
      ),
    );
    _applySearch();
  }

  /// Quita el alcance de marca y repite la búsqueda global con el texto.
  void clearScopeBrand() {
    _debounceTimer?.cancel();
    _cancelAnalysis();
    emit(state.copyWith(clearScopeBrand: true));
    _applySearch();
  }

  /// Reemplaza el texto por una sugerencia; nunca se hace sin que el usuario toque.
  void applySuggestion(String suggestion) {
    _debounceTimer?.cancel();
    _cancelOtherYears();
    _cancelAnalysis();
    emit(
      state.copyWith(
        query: suggestion,
        clearOtherYears: true,
        otherYearsFailed: false,
      ),
    );
    _applySearch();
  }

  /// Repite una búsqueda reciente (guarda solo el texto, sin alcance).
  Future<void> useRecent(RecentSearchEntity recent) async {
    _debounceTimer?.cancel();
    _cancelOtherYears();
    _cancelAnalysis();
    emit(
      state.copyWith(
        query: recent.text,
        clearScopeBrand: true,
        clearOtherYears: true,
        otherYearsFailed: false,
      ),
    );
    _applySearch();
    await _saveRecent(recent.text);
  }

  /// Busca el texto en los años más cercanos del catálogo del mercado.
  void searchInOtherYears() {
    final scope = state.scope;
    if (scope == null || !state.hasText || _otherYearsSubscription != null) {
      return;
    }
    final subscription =
        searchOtherYears(
          scope: scope,
          query: state.query,
          availableYears: contextSource.availableYears,
        ).listen(
          (status) {
            if (isClosed || state.scope != scope) return;
            emit(state.copyWith(otherYears: status));
            // Con filtros que lo necesitan, los años nuevos se analizan solos.
            _ensureAnalysis();
          },
          onError: (Object _) {
            if (isClosed) return;
            emit(state.copyWith(clearOtherYears: true, otherYearsFailed: true));
          },
        );
    subscription.onDone(() {
      if (identical(_otherYearsSubscription, subscription)) {
        _otherYearsSubscription = null;
      }
    });
    _otherYearsSubscription = subscription;
    emit(state.copyWith(otherYearsFailed: false));
  }

  /// Cancela la búsqueda en otros años y vuelve a ofrecerla.
  void cancelOtherYears() {
    _cancelOtherYears();
    emit(state.copyWith(clearOtherYears: true, otherYearsFailed: false));
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

  // Calcula resultados, marcas y sugerencias con el índice que haya.
  void _applySearch() {
    if (isClosed) return;
    final scope = state.scope;
    // Las marcas del índice salen con el primer avance y no cambian después.
    final newBrands = scope == null || state.brands.isNotEmpty
        ? null
        : getIndexBrands(scope);
    final knownBrands = newBrands ?? state.brands;
    // Tras un cambio de mercado, la marca se conserva solo si existe en el nuevo.
    final brandLost = _isBrandMissing(state.scopeBrand, knownBrands);
    final brand = brandLost ? null : state.scopeBrand;
    final hasText = state.hasText;
    final canOffer =
        scope != null &&
        contextSource.availableYears.any((year) => year != scope.year);
    final SearchResponseEntity response;
    if (scope != null && brand != null && !hasText) {
      response = SearchResponseEntity(primary: getBrandGroups(scope, brand));
    } else if (scope != null && hasText) {
      response = searchWithScope(scope, state.query, scopeBrand: brand);
    } else {
      response = SearchResponseEntity.empty;
    }
    // Solo con el índice completo hay certeza de que no hay coincidencias.
    final finished = state.indexStatus?.phase == SearchIndexPhase.ready;
    // Un avance del índice no salta la espera: el texto aún puede estar cambiando.
    final settling = _debounceTimer?.isActive ?? false;
    emit(
      state.copyWith(
        results: response.primary,
        otherResults: response.others,
        brandMatches: response.brandMatches,
        // Sin nada que mostrar y con el índice completo, se proponen correcciones.
        suggestions:
            scope != null &&
                hasText &&
                response.isEmpty &&
                finished &&
                !settling
            ? suggestTerms(scope, state.query)
            : const [],
        searchedText: hasText ? TextNormalizer.normalize(state.query) : '',
        canOfferOtherYears: canOffer,
        isSearching: settling,
        clearScopeBrand: brandLost,
        brands: newBrands,
      ),
    );
    // Con filtros que lo necesitan, los resultados nuevos se analizan solos.
    _ensureAnalysis();
  }

  // Verdadero si hay marca elegida, el índice ya conoce sus marcas y no está.
  bool _isBrandMissing(String? brand, List<String> known) {
    if (brand == null || known.isEmpty) return false;
    final wanted = TextNormalizer.normalize(brand);
    return !known.any((name) => TextNormalizer.normalize(name) == wanted);
  }

  // Otro mercado o año: cancela y reconstruye; conserva texto y marca elegida.
  void _onScopeChanged(SearchScopeEntity? scope) {
    if (scope == state.scope) return;
    _cancelBuild();
    _cancelOtherYears();
    _cancelAnalysis();
    emit(
      state.copyWith(
        // Otro mercado o año: los filtros y lo analizado ya no valen.
        filters: SearchFiltersEntity.none,
        traits: const {},
        scope: scope,
        clearScope: scope == null,
        clearIndexStatus: true,
        indexFailed: false,
        clearOtherYears: true,
        otherYearsFailed: false,
        canOfferOtherYears: false,
        results: const [],
        otherResults: const [],
        brandMatches: const [],
        suggestions: const [],
        brands: const [],
        searchedText: '',
      ),
    );
    if (scope != null && _indexWanted) _startBuild(scope);
  }

  void _cancelBuild() {
    _indexRerunTimer?.cancel();
    _indexRetryTimer?.cancel();
    _indexRetryAttempts = 0;
    unawaited(_indexSubscription?.cancel());
    _indexSubscription = null;
    buildIndex.cancel();
  }

  /// Elige o quita una motorización del filtro.
  void toggleEngine(SearchEngineOption option) {
    final engines = {...state.filters.engines};
    if (!engines.remove(option)) engines.add(option);
    _setFilters(state.filters.copyWith(engines: engines));
  }

  /// Elige o quita una marca del filtro.
  void toggleBrandFilter(String brand) {
    final brands = {...state.filters.brands};
    if (!brands.remove(brand)) brands.add(brand);
    _setFilters(state.filters.copyWith(brands: brands));
  }

  /// Elige un orden; tocar el que ya está elegido vuelve al orden original.
  void setSortOrder(SearchSortOrder sort) {
    final next = state.filters.sort == sort ? SearchSortOrder.relevance : sort;
    _setFilters(state.filters.copyWith(sort: next));
  }

  /// Limpia de una vez el texto, el alcance de marca y los filtros.
  void clearAll() {
    _debounceTimer?.cancel();
    _cancelOtherYears();
    _cancelAnalysis();
    emit(
      state.copyWith(
        query: '',
        clearScopeBrand: true,
        filters: SearchFiltersEntity.none,
        results: const [],
        otherResults: const [],
        brandMatches: const [],
        suggestions: const [],
        searchedText: '',
        isSearching: false,
        clearOtherYears: true,
        otherYearsFailed: false,
      ),
    );
  }

  /// Quita todos los filtros y el orden.
  void clearFilters() => _setFilters(SearchFiltersEntity.none);

  /// La hoja de filtros se abrió: analiza los resultados que falten.
  void filtersSheetOpened() {
    _filtersSheetOpen = true;
    _ensureAnalysis();
  }

  /// La hoja se cerró: el análisis se cancela salvo que los filtros lo necesiten.
  void filtersSheetClosed() {
    _filtersSheetOpen = false;
    if (!state.filters.needsTraits) _cancelAnalysis();
  }

  void _setFilters(SearchFiltersEntity filters) {
    if (filters == state.filters) return;
    emit(state.copyWith(filters: filters));
    _ensureAnalysis();
  }

  // Pide los rasgos que faltan, solo con la hoja abierta o filtros que los usan.
  void _ensureAnalysis() {
    if (isClosed || !(_filtersSheetOpen || state.filters.needsTraits)) return;
    // Los otros años solo se analizan si los filtros dependen de los rasgos.
    final candidates = [
      ...state.analysisCandidates,
      if (state.filters.needsTraits) ...state.otherYearsCandidates,
    ];
    final missing = [
      for (final result in candidates)
        if (!state.traits.containsKey(result.traitsKey)) result,
    ];
    if (missing.isEmpty) return;
    if (_analysisSubscription != null) {
      _analysisRerun = true;
      return;
    }
    final subscription = analysisRunner.run(missing).listen((update) {
      if (isClosed) return;
      emit(
        state.copyWith(
          traits: {...state.traits, update.result.traitsKey: update.traits},
        ),
      );
    });
    subscription.onDone(() {
      if (!identical(_analysisSubscription, subscription)) return;
      _analysisSubscription = null;
      if (isClosed) return;
      emit(state.copyWith(isAnalyzing: false));
      if (_analysisRerun) {
        _analysisRerun = false;
        _ensureAnalysis();
      }
    });
    _analysisSubscription = subscription;
    emit(state.copyWith(isAnalyzing: true));
  }

  void _cancelAnalysis() {
    _analysisRerun = false;
    final subscription = _analysisSubscription;
    if (subscription == null) return;
    _analysisSubscription = null;
    unawaited(subscription.cancel());
    if (!isClosed) emit(state.copyWith(isAnalyzing: false));
  }

  void _cancelOtherYears() {
    unawaited(_otherYearsSubscription?.cancel());
    _otherYearsSubscription = null;
    searchOtherYears.cancel();
  }

  void _startBuild(SearchScopeEntity scope, {bool retryFailedOnly = false}) {
    unawaited(_indexSubscription?.cancel());
    emit(state.copyWith(indexFailed: false));
    final subscription = buildIndex(scope, retryFailedOnly: retryFailedOnly)
        .listen(
          (status) {
            if (isClosed || state.scope != scope) return;
            final first = state.indexStatus == null;
            emit(state.copyWith(indexStatus: status));
            if (status.phase == SearchIndexPhase.building && !first) {
              // Mientras avanza, los eventos se agrupan en una sola consulta.
              _scheduleIndexRerun();
              return;
            }
            // Primer avance, listo o parcial: la consulta se repite de inmediato.
            _indexRerunTimer?.cancel();
            _applySearch();
            if (status.phase == SearchIndexPhase.ready) {
              _indexRetryTimer?.cancel();
              _indexRetryAttempts = 0;
            } else if (status.phase == SearchIndexPhase.partial) {
              _scheduleIndexRetry(scope, retryFailedOnly: true);
            }
          },
          onError: (Object _) {
            if (isClosed || state.scope != scope) return;
            emit(state.copyWith(indexFailed: true));
            // Sin siquiera las marcas: se reintenta todo, con retroceso.
            if (state.indexStatus == null) {
              _scheduleIndexRetry(scope, retryFailedOnly: false);
            }
          },
        );
    subscription.onDone(() {
      if (identical(_indexSubscription, subscription)) {
        _indexSubscription = null;
      }
    });
    _indexSubscription = subscription;
  }

  // Repite la consulta tras una pausa corta; los avances intermedios se funden.
  void _scheduleIndexRerun() {
    if (_indexRerunTimer?.isActive ?? false) return;
    _indexRerunTimer = Timer(
      const Duration(milliseconds: SearchConfig.indexRerunCoalesceMilliseconds),
      () {
        _indexRerunTimer = null;
        _applySearch();
      },
    );
  }

  // Reintenta solo, con espera creciente, hasta el tope de intentos.
  void _scheduleIndexRetry(
    SearchScopeEntity scope, {
    required bool retryFailedOnly,
  }) {
    if (!_indexWanted ||
        _indexRetryAttempts >= SearchConfig.indexRetryMaxAttempts) {
      return;
    }
    final factor = pow(
      SearchConfig.indexRetryBackoffFactor,
      _indexRetryAttempts,
    );
    final delay = Duration(
      milliseconds:
          SearchConfig.indexRetryBaseDelayMilliseconds * factor.toInt(),
    );
    _indexRetryTimer?.cancel();
    _indexRetryTimer = Timer(delay, () {
      _indexRetryTimer = null;
      if (isClosed || state.scope != scope) return;
      final stillNeeded = retryFailedOnly ? state.isPartial : state.indexFailed;
      if (!stillNeeded) return;
      _indexRetryAttempts++;
      _startBuild(scope, retryFailedOnly: retryFailedOnly);
    });
  }

  @override
  Future<void> close() async {
    _indexRerunTimer?.cancel();
    _indexRetryTimer?.cancel();
    _debounceTimer?.cancel();
    await _scopeSubscription?.cancel();
    await _indexSubscription?.cancel();
    await _otherYearsSubscription?.cancel();
    await _analysisSubscription?.cancel();
    buildIndex.cancel();
    searchOtherYears.cancel();
    await contextSource.close();
    return super.close();
  }
}
