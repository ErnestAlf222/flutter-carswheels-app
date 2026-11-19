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

const SortStrategy<SuggestionCandidate> suggestionSort =
    AdaptiveSortStrategy<SuggestionCandidate>(
      smallListStrategy: BubbleSortStrategy<SuggestionCandidate>(),
      largeListStrategy: ShellSortStrategy<SuggestionCandidate>(),
    );

const SortStrategy<SearchResultEntity> resultSort =
    AdaptiveSortStrategy<SearchResultEntity>(
      smallListStrategy: BubbleSortStrategy<SearchResultEntity>(),
      largeListStrategy: ShellSortStrategy<SearchResultEntity>(),
    );

const SortStrategy<int> yearSort = AdaptiveSortStrategy<int>(
  smallListStrategy: BubbleSortStrategy<int>(),
  largeListStrategy: ShellSortStrategy<int>(),
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
  Future<List<SearchGroupEntity>> fetchGroups(
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
      return [
        for (final name in groupsByBrand[brand]!)
          SearchGroupEntity(name: name, variantNames: [name]),
      ];
    } finally {
      inFlight--;
    }
  }
}

/// Rasgos falsos: por nombre de grupo, con cuenta de pedidos y control de ritmo.
class FakeSearchTraitsSource implements SearchTraitsSource {
  /// Rasgos por nombre de grupo; sin entrada devuelve "sin dato".
  final Map<String, SearchResultTraitsEntity> byGroup = {};

  /// Grupos cuyo pedido falla.
  final Set<String> failing = {};
  final List<String> requests = [];
  int inFlight = 0;
  int maxInFlight = 0;

  /// Si no es nulo, cada pedido espera a que se complete.
  Completer<void>? gate;

  @override
  Future<SearchResultTraitsEntity> traitsOf(SearchResultEntity result) async {
    requests.add(result.groupName ?? result.brand);
    inFlight++;
    if (inFlight > maxInFlight) maxInFlight = inFlight;
    try {
      final pending = gate;
      if (pending != null) await pending.future;
      if (failing.contains(result.groupName)) throw StateError('falla');
      return byGroup[result.groupName] ?? SearchResultTraitsEntity.unknown;
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

  /// Años del catálogo del mercado, del más reciente al más antiguo.
  List<int> years = const [2026, 2025, 2024, 2023];

  @override
  SearchScopeEntity? get scope => _scope;

  @override
  Stream<SearchScopeEntity?> get scopeChanges => _changes.stream;

  @override
  List<int> get availableYears => years;

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
    this.analysisConcurrency = SearchConfig.analysisConcurrency,
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
      searchWithScope: SearchWithScopeUseCase(
        store: store,
        ranker: const SearchResultRanker(sortStrategy: rankedSort),
      ),
      suggestTerms: SuggestSearchTermsUseCase(
        store: store,
        sortStrategy: suggestionSort,
      ),
      searchOtherYears: otherYears,
      getBrandGroups: GetBrandGroupsUseCase(
        store: store,
        ranker: const SearchResultRanker(sortStrategy: rankedSort),
      ),
      getIndexBrands: GetIndexBrandsUseCase(
        store: store,
        sortStrategy: const AdaptiveSortStrategy<String>(
          smallListStrategy: BubbleSortStrategy<String>(),
          largeListStrategy: ShellSortStrategy<String>(),
        ),
      ),
      addRecent: AddRecentSearchUseCase(
        datasource: recents,
        clock: clock ?? DateTime.now,
      ),
      getRecents: GetRecentSearchesUseCase(recents),
      removeRecent: RemoveRecentSearchUseCase(recents),
      clearRecents: ClearRecentSearchesUseCase(recents),
      analysisRunner: SearchAnalysisRunner(
        source: traits,
        maxConcurrent: analysisConcurrency,
      ),
      filterService: filterService,
      debounce: debounce,
    );
  }

  final Duration debounce;
  final DateTime Function()? clock;
  final int analysisConcurrency;

  /// Rasgos falsos de los resultados; la prueba los fija por clave de grupo.
  final FakeSearchTraitsSource traits = FakeSearchTraitsSource();
  final SearchFilterService filterService = const SearchFilterService(
    sortStrategy: resultSort,
  );
  final FakeSearchCatalogSource source;
  final SearchScopeEntity? initialScope;

  // Se crea al primer uso, dentro de la zona de reloj falso de la prueba.
  late final FakeSearchContextSource context = FakeSearchContextSource(
    initialScope,
  );
  final FakeRecentSearches recents;
  late final SearchIndexStore store;
  late final BuildSearchIndexUseCase build;

  // Otros años: índice propio sobre el mismo almacén y el mismo origen.
  late final SearchOtherYearsUseCase otherYears = SearchOtherYearsUseCase(
    buildIndex: BuildSearchIndexUseCase(
      source: source,
      store: store,
      sortStrategy: postingSort,
    ),
    searchCatalog: SearchCatalogUseCase(
      store: store,
      ranker: const SearchResultRanker(sortStrategy: rankedSort),
    ),
    selector: const NearestYearsSelector(sortStrategy: yearSort),
  );
}
