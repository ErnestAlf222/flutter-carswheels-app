import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/search.dart';

const SortStrategy<SearchPosting> postingSort =
    AdaptiveSortStrategy<SearchPosting>(
      smallListStrategy: BubbleSortStrategy<SearchPosting>(),
      largeListStrategy: ShellSortStrategy<SearchPosting>(),
    );

const SortStrategy<RankedSearchEntry> rankedSort =
    AdaptiveSortStrategy<RankedSearchEntry>(
      smallListStrategy: BubbleSortStrategy<RankedSearchEntry>(),
      largeListStrategy: ShellSortStrategy<RankedSearchEntry>(),
    );

const SearchScopeEntity usScope = SearchScopeEntity(
  marketCode: 'us',
  year: 2025,
);
const SearchScopeEntity mxScope = SearchScopeEntity(
  marketCode: 'mx',
  year: 2025,
);

/// Fila de grupo para armar índices en pruebas.
SearchEntryEntity groupEntry(String brand, String name) =>
    SearchEntryEntity(brand: brand, groupName: name);

/// Origen falso: grupos por marca, fallas y control manual de las respuestas.
class FakeSearchCatalogSource implements SearchCatalogSource {
  FakeSearchCatalogSource(this.groupsByBrand);

  final Map<String, List<String>> groupsByBrand;
  final Set<String> failingBrands = {};

  /// Si es verdadero, pedir las marcas falla (sin conexión).
  bool failBrands = false;
  final List<String> groupRequests = [];
  final List<SearchScopeEntity> scopes = [];
  int brandRequests = 0;
  int inFlight = 0;
  int maxInFlight = 0;

  /// Si no es nulo, cada petición de grupos espera a que se complete.
  Completer<void>? gate;

  @override
  Future<List<String>> fetchBrands(SearchScopeEntity scope) async {
    brandRequests++;
    scopes.add(scope);
    if (failBrands) throw StateError('sin conexión');
    return groupsByBrand.keys.toList();
  }

  @override
  Future<List<String>> fetchGroupNames(
    SearchScopeEntity scope,
    String brand,
  ) async {
    groupRequests.add(brand);
    inFlight++;
    if (inFlight > maxInFlight) maxInFlight = inFlight;
    try {
      final pending = gate;
      if (pending != null) await pending.future;
      if (failingBrands.contains(brand)) throw StateError('falla $brand');
      return groupsByBrand[brand]!;
    } finally {
      inFlight--;
    }
  }
}

/// Recientes en memoria.
class FakeRecentSearches implements RecentSearchesDatasource {
  List<RecentSearchEntity> stored = [];

  @override
  Future<List<RecentSearchEntity>> readAll() async => List.of(stored);

  @override
  Future<void> replaceAll(List<RecentSearchEntity> searches) async {
    stored = List.of(searches);
  }
}

/// Contexto falso: el alcance lo fija la prueba y cada cambio se anuncia.
class FakeSearchContextSource implements SearchContextSource {
  FakeSearchContextSource([this._scope]);

  SearchScopeEntity? _scope;
  final StreamController<SearchScopeEntity?> _changes =
      StreamController<SearchScopeEntity?>.broadcast(sync: true);
  bool closed = false;

  @override
  SearchScopeEntity? get scope => _scope;

  @override
  Stream<SearchScopeEntity?> get scopeChanges => _changes.stream;

  /// Cambia el alcance y lo anuncia.
  void change(SearchScopeEntity? scope) {
    _scope = scope;
    _changes.add(scope);
  }

  @override
  Future<void> close() async {
    closed = true;
    await _changes.close();
  }
}

/// Todo lo que arma un SearchCubit de prueba, a la vista de la prueba.
class SearchHarness {
  SearchHarness({
    Map<String, List<String>>? groupsByBrand,
    this.initialScope = usScope,
    this.debounce = const Duration(milliseconds: 300),
    this.clock,
  }) : source = FakeSearchCatalogSource(
         groupsByBrand ??
             {
               'Toyota': ['Camry', 'Corolla', 'RAV4'],
               'Honda': ['Accord', 'Civic'],
               'Hyundai': ['Ioniq 5', 'Elantra'],
             },
       ),
       recents = FakeRecentSearches() {
    store = SearchIndexStore();
    build = BuildSearchIndexUseCase(
      source: source,
      store: store,
      sortStrategy: postingSort,
    );
  }

  // Se crea al primer uso: así queda en la zona de reloj falso de la prueba.
  late final SearchCubit cubit = _buildCubit();

  SearchCubit _buildCubit() {
    return SearchCubit(
      contextSource: context,
      buildIndex: build,
      searchCatalog: SearchCatalogUseCase(
        store: store,
        ranker: const SearchResultRanker(sortStrategy: rankedSort),
      ),
      getBrandGroups: GetBrandGroupsUseCase(
        store: store,
        ranker: const SearchResultRanker(sortStrategy: rankedSort),
      ),
      getTopBrands: GetTopBrandsUseCase(
        store: store,
        sortStrategy: const AdaptiveSortStrategy<BrandGroupCount>(
          smallListStrategy: BubbleSortStrategy<BrandGroupCount>(),
          largeListStrategy: ShellSortStrategy<BrandGroupCount>(),
        ),
      ),
      addRecent: AddRecentSearchUseCase(
        datasource: recents,
        clock: clock ?? DateTime.now,
      ),
      getRecents: GetRecentSearchesUseCase(recents),
      removeRecent: RemoveRecentSearchUseCase(recents),
      clearRecents: ClearRecentSearchesUseCase(recents),
      debounce: debounce,
    );
  }

  final Duration debounce;
  final DateTime Function()? clock;
  final FakeSearchCatalogSource source;
  final SearchScopeEntity? initialScope;

  // Se crea al primer uso, dentro de la zona de reloj falso de la prueba.
  late final FakeSearchContextSource context = FakeSearchContextSource(
    initialScope,
  );
  final FakeRecentSearches recents;
  late final SearchIndexStore store;
  late final BuildSearchIndexUseCase build;
}
