import 'package:cars_wheels_app/core/algorithms/sort_strategy.dart';

// Secuencia de Knuth: h = 3h + 1, empezando en 1.
const int _knuthMultiplier = 3;
const int _knuthIncrement = 1;
const int _initialGap = 1;

/// Ordenamiento Shell con la secuencia de Knuth (1, 4, 13, 40, ...).
/// No es estable: los elementos iguales pueden cambiar de orden relativo.
class ShellSortStrategy<T> implements SortStrategy<T> {
  const ShellSortStrategy();

  @override
  List<T> sort(List<T> items, Comparator<T> compare) {
    final result = List<T>.of(items);
    final gaps = _gapsDescending(result.length, _initialGap);
    for (final gap in gaps) {
      final starts = List<int>.generate(
        result.length - gap,
        (offset) => offset + gap,
      );
      for (final start in starts) {
        _insert(result, start, gap, result[start], compare);
      }
    }
    return result;
  }

  // Saltos de Knuth menores que la longitud, de mayor a menor.
  List<int> _gapsDescending(int length, int gap) {
    if (gap >= length) return const [];
    final next = gap * _knuthMultiplier + _knuthIncrement;
    return [..._gapsDescending(length, next), gap];
  }

  // Desplaza hacia atrás los mayores que value y lo coloca en su posición.
  void _insert(
    List<T> list,
    int position,
    int gap,
    T value,
    Comparator<T> compare,
  ) {
    final previous = position - gap;
    if (previous >= 0 && compare(list[previous], value) > 0) {
      list[position] = list[previous];
      _insert(list, previous, gap, value, compare);
    } else {
      list[position] = value;
    }
  }
}
