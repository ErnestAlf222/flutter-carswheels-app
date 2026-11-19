import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_result_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_scope_entity.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_index_store.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_result_ranker.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_tokenizer.dart';

/// Busca marcas y grupos de modelo en el índice en memoria de un mercado y año.
class SearchCatalogUseCase {
  const SearchCatalogUseCase({required this.store, required this.ranker});

  final SearchIndexStore store;
  final SearchResultRanker ranker;

  /// Vacío si la consulta no llega al mínimo o no hay índice para el alcance.
  List<SearchResultEntity> call(SearchScopeEntity scope, String query) {
    if (TextNormalizer.normalize(query).length < SearchConfig.minQueryLength) {
      return const [];
    }
    final record = store.recordOf(scope.key);
    if (record == null) return const [];
    final matches = record.index.match(SearchTokenizer.queryTokens(query));
    return ranker.rank(matches: matches, query: query, scope: scope);
  }
}
