import 'package:cars_wheels_app/core/algorithms/sort_strategy.dart';
import 'package:cars_wheels_app/core/config/config.dart';

/// Elige burbuja para listas pequeñas y Shell para el resto.
class AdaptiveSortStrategy<T> implements SortStrategy<T> {
  const AdaptiveSortStrategy({
    required this.smallListStrategy,
    required this.largeListStrategy,
  });

  final SortStrategy<T> smallListStrategy;
  final SortStrategy<T> largeListStrategy;

  @override
  List<T> sort(List<T> items, Comparator<T> compare) {
    final strategy = items.length <= AlgorithmsConfig.bubbleSortMaxItems
        ? smallListStrategy
        : largeListStrategy;
    return strategy.sort(items, compare);
  }
}
