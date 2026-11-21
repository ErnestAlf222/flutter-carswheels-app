import 'dart:math';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_entry_entity.dart';
import 'package:cars_wheels_app/features/search/domain/feed/feed.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_index_status_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_response_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_result_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_scope_entity.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_index_store.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_result_ranker.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_tokenizer.dart';

/// Búsqueda global con alcance suave: la marca elegida reordena, no limita.
class SearchWithScopeUseCase {
  const SearchWithScopeUseCase({required this.store, required this.ranker});

  final SearchIndexStore store;
  final SearchResultRanker ranker;

  /// Con [scopeBrand], primero los modelos de esa marca y luego los de las demás.
  /// Vacío si el texto no llega al mínimo o no hay índice para el alcance.
  SearchResponseEntity call(
    SearchScopeEntity scope,
    String query, {
    String? scopeBrand,
  }) {
    if (TextNormalizer.normalize(query).length < SearchConfig.minQueryLength) {
      return SearchResponseEntity.empty;
    }
    final record = store.recordOf(scope.key);
    if (record == null) return SearchResponseEntity.empty;
    final matches = record.index.match(SearchTokenizer.queryTokens(query));
    final groups = [
      for (final entry in matches)
        if (entry.groupName != null) entry,
    ];
    final inScope = scopeBrand == null
        ? groups
        : [
            for (final entry in groups)
              if (entry.brand == scopeBrand) entry,
          ];
    final primary = ranker.rank(matches: inScope, query: query, scope: scope);
    final others = scopeBrand == null
        ? const <SearchEntryEntity>[]
        : [
            for (final entry in groups)
              if (entry.brand != scopeBrand) entry,
          ];
    final remaining = SearchConfig.maxResults - primary.length;
    return SearchResponseEntity(
      primary: primary,
      others: others.isEmpty || remaining <= 0
          ? const []
          : ranker.rank(
              matches: others,
              query: query,
              scope: scope,
              limit: remaining,
            ),
      brandMatches: _brandMatches(matches, query, scopeBrand),
    );
  }

  /// Hasta [count] modelos al azar del índice ya construido del alcance.
  ///
  /// El mismo [seed] da siempre la misma elección: no usa red, solo lo que el
  /// índice tiene. Prefiere marcas distintas y, si faltan, completa con otras.
  /// Con el índice aún en obra y menos de [count] modelos, devuelve nada.
  List<SearchResultEntity> picks(
    SearchScopeEntity scope, {
    required int seed,
    int count = SearchConfig.picksCount,
  }) {
    final record = store.recordOf(scope.key);
    if (record == null) return const [];
    final groups = [
      for (final entry in record.index.entries)
        if (entry.groupName != null) entry,
    ];
    final building = record.status.phase == SearchIndexPhase.building;
    if (groups.isEmpty || (building && groups.length < count)) return const [];
    final shuffled = [...groups]..shuffle(Random(seed));
    final brands = <String>{};
    final chosen = <SearchEntryEntity>[];
    // Primera pasada: una por marca; segunda: lo que falte.
    for (final entry in shuffled) {
      if (chosen.length >= count) break;
      if (brands.add(entry.brand)) chosen.add(entry);
    }
    for (final entry in shuffled) {
      if (chosen.length >= count) break;
      if (!chosen.contains(entry)) chosen.add(entry);
    }
    return [
      for (final entry in chosen)
        SearchResultEntity(
          brand: entry.brand,
          groupName: entry.groupName,
          variantNames: entry.variantNames,
          year: scope.year,
          marketCode: scope.marketCode,
        ),
    ];
  }

  /// La siguiente página del feed del alcance: modelos del índice en orden
  /// aleatorio determinista por [seed], sin los de [exclude] (sugerencias y ya
  /// mostrados). Sin red: solo lo que el índice ya tiene.
  SearchFeedPageEntity feedPage(
    SearchScopeEntity scope, {
    required int seed,
    required Set<String> exclude,
    required int pageSize,
    SearchFeedPlanner planner = const SearchFeedPlanner(),
  }) {
    final record = store.recordOf(scope.key);
    if (record == null) return SearchFeedPageEntity.empty;
    final plan = planner.plan(
      record.index.entries,
      seed: seed,
      exclude: exclude,
      pageSize: pageSize,
    );
    return SearchFeedPageEntity(
      results: [
        for (final entry in plan.page)
          SearchResultEntity(
            brand: entry.brand,
            groupName: entry.groupName,
            variantNames: entry.variantNames,
            year: scope.year,
            marketCode: scope.marketCode,
          ),
      ],
      remaining: plan.remaining,
      isBuilding: record.status.phase == SearchIndexPhase.building,
    );
  }

  // Marcas cuyo nombre coincide por prefijo: la exacta primero, luego el orden del índice.
  List<String> _brandMatches(
    List<SearchEntryEntity> matches,
    String query,
    String? scopeBrand,
  ) {
    final normalizedQuery = TextNormalizer.normalize(query);
    final brands = [
      for (final entry in matches)
        if (entry.groupName == null && entry.brand != scopeBrand) entry.brand,
    ];
    final exact = [
      for (final brand in brands)
        if (TextNormalizer.normalize(brand) == normalizedQuery) brand,
    ];
    final rest = [
      for (final brand in brands)
        if (!exact.contains(brand)) brand,
    ];
    return [...exact, ...rest].take(SearchConfig.maxBrandMatches).toList();
  }
}
