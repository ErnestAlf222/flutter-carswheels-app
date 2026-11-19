import 'package:cars_wheels_app/core/core.dart';

/// Elige los años del catálogo más cercanos al vigente (sin incluirlo).
class NearestYearsSelector {
  const NearestYearsSelector({required this.sortStrategy});

  final SortStrategy<int> sortStrategy;

  /// Hasta [count] años; a igual distancia va primero el más reciente.
  List<int> select({
    required List<int> available,
    required int currentYear,
    int count = SearchConfig.otherYearsCount,
  }) {
    final candidates = {
      for (final year in available)
        if (year != currentYear) year,
    }.toList();
    final sorted = sortStrategy.sort(candidates, (a, b) {
      final byDistance = (a - currentYear).abs().compareTo(
        (b - currentYear).abs(),
      );
      return byDistance != 0 ? byDistance : b.compareTo(a);
    });
    return sorted.take(count).toList();
  }
}
