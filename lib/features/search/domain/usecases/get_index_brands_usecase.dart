import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_scope_entity.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_index_store.dart';

/// Todas las marcas del índice del alcance, en orden alfabético.
class GetIndexBrandsUseCase {
  const GetIndexBrandsUseCase({
    required this.store,
    required this.sortStrategy,
  });

  final SearchIndexStore store;
  final SortStrategy<String> sortStrategy;

  /// Vacío si no hay índice para el alcance.
  List<String> call(SearchScopeEntity scope) {
    final record = store.recordOf(scope.key);
    if (record == null) return const [];
    final brands = {for (final entry in record.index.entries) entry.brand};
    return sortStrategy.sort(brands.toList(), _compare);
  }

  int _compare(String a, String b) {
    final byName = TextNormalizer.normalize(a)
        .compareTo(TextNormalizer.normalize(b));
    return byName != 0 ? byName : a.compareTo(b);
  }
}
