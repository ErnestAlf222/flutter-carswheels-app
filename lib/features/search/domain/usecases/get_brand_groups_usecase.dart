import 'package:cars_wheels_app/features/search/domain/entities/search_result_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_scope_entity.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_index_store.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_result_ranker.dart';

/// Lista los grupos de una marca ya indexados, en orden alfabético y sin corte.
class GetBrandGroupsUseCase {
  const GetBrandGroupsUseCase({required this.store, required this.ranker});

  final SearchIndexStore store;
  final SearchResultRanker ranker;

  /// Vacío si no hay índice para el alcance o la marca aún no trae grupos.
  List<SearchResultEntity> call(SearchScopeEntity scope, String brand) {
    final record = store.recordOf(scope.key);
    if (record == null) return const [];
    final groups = [
      for (final entry in record.index.entries)
        if (entry.brand == brand && entry.groupName != null) entry,
    ];
    return ranker.rank(
      matches: groups,
      query: brand,
      scope: scope,
      limit: null,
    );
  }
}
