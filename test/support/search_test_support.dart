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
