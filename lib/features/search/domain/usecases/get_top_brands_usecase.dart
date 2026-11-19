import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_scope_entity.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_index_store.dart';

/// Marca con el número de grupos indexados.
class BrandGroupCount {
  const BrandGroupCount({required this.brand, required this.groupCount});

  final String brand;
  final int groupCount;
}

/// Marcas con más grupos en el índice del alcance, para los accesos rápidos.
class GetTopBrandsUseCase {
  const GetTopBrandsUseCase({required this.store, required this.sortStrategy});

  final SearchIndexStore store;
  final SortStrategy<BrandGroupCount> sortStrategy;

  /// Las [count] marcas con más grupos; a igual cantidad, alfabético.
  List<String> call(SearchScopeEntity scope, int count) {
    final record = store.recordOf(scope.key);
    if (record == null) return const [];
    final counts = <String, int>{};
    for (final entry in record.index.entries) {
      counts[entry.brand] =
          (counts[entry.brand] ?? 0) + (entry.groupName == null ? 0 : 1);
    }
    final sorted = sortStrategy.sort([
      for (final item in counts.entries)
        BrandGroupCount(brand: item.key, groupCount: item.value),
    ], _compare);
    return [for (final item in sorted.take(count)) item.brand];
  }

  int _compare(BrandGroupCount a, BrandGroupCount b) {
    final byCount = b.groupCount.compareTo(a.groupCount);
    if (byCount != 0) return byCount;
    final byName = TextNormalizer.normalize(a.brand)
        .compareTo(TextNormalizer.normalize(b.brand));
    return byName != 0 ? byName : a.brand.compareTo(b.brand);
  }
}
