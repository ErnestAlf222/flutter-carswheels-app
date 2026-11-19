import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_result_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_scope_entity.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_index_store.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_result_ranker.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_tokenizer.dart';

/// Busca grupos de modelo en el índice en memoria de un mercado y año.
class SearchCatalogUseCase {
  const SearchCatalogUseCase({required this.store, required this.ranker});

  final SearchIndexStore store;
  final SearchResultRanker ranker;

  /// Solo grupos (las marcas se eligen aparte); con [brand], solo de esa marca.
  /// Vacío si la consulta no llega al mínimo o no hay índice para el alcance.
  List<SearchResultEntity> call(
    SearchScopeEntity scope,
    String query, {
    String? brand,
  }) {
    if (TextNormalizer.normalize(query).length < SearchConfig.minQueryLength) {
      return const [];
    }
    final record = store.recordOf(scope.key);
    if (record == null) return const [];
    final matches = record.index.match(SearchTokenizer.queryTokens(query));
    return ranker.rank(
      matches: [
        for (final entry in matches)
          if (entry.groupName != null &&
              (brand == null || entry.brand == brand))
            entry,
      ],
      query: query,
      scope: scope,
    );
  }
}
