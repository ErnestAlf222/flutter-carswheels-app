import 'package:cars_wheels_app/core/algorithms/sort_strategy.dart';

const int _indexStep = 1;

/// Ordenamiento burbuja con corte anticipado; es estable.
class BubbleSortStrategy<T> implements SortStrategy<T> {
  const BubbleSortStrategy();

  @override
  List<T> sort(List<T> items, Comparator<T> compare) {
    final result = List<T>.of(items);
    _runPasses(result, result.length - _indexStep, compare);
    return result;
  }

  // Repite pasadas sobre [0, lastIndex] hasta que una no intercambie nada.
  void _runPasses(List<T> list, int lastIndex, Comparator<T> compare) {
    if (lastIndex <= 0) return;
    final swapped = _pass(list, 0, lastIndex, compare);
    if (swapped) _runPasses(list, lastIndex - _indexStep, compare);
  }

  // Una pasada: compara pares vecinos y devuelve si hubo intercambios.
  bool _pass(List<T> list, int index, int lastIndex, Comparator<T> compare) {
    if (index >= lastIndex) return false;
    final next = index + _indexStep;
    final needsSwap = compare(list[index], list[next]) > 0;
    if (needsSwap) {
      final held = list[index];
      list[index] = list[next];
      list[next] = held;
    }
    final restSwapped = _pass(list, next, lastIndex, compare);
    return needsSwap || restSwapped;
  }
}
