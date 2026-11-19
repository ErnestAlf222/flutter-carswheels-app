import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_entry_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_response_entity.dart';
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
