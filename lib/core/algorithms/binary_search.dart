const int _notFound = -1;
const int _halfDivisor = 2;
const int _nextStep = 1;

/// Búsquedas binarias recursivas sobre listas ya ordenadas.
class BinarySearch {
  const BinarySearch._();

  /// Primer índice cuyo elemento no va antes del objetivo.
  static int lowerBound<T>(List<T> sorted, int Function(T) compareToTarget) =>
      _lowerBound(sorted, compareToTarget, 0, sorted.length);

  /// Índice de una coincidencia exacta o -1.
  static int indexOf<T>(List<T> sorted, int Function(T) compareToTarget) {
    final index = lowerBound(sorted, compareToTarget);
    final found = index < sorted.length && compareToTarget(sorted[index]) == 0;
    return found ? index : _notFound;
  }

  /// Elementos cuya clave empieza con el prefijo.
  static List<T> withPrefix<T>(
    List<T> sorted,
    String prefix,
    String Function(T) keyOf,
  ) {
    final start = lowerBound(sorted, (item) => keyOf(item).compareTo(prefix));
    final end = _prefixEnd(sorted, start, prefix, keyOf);
    return sorted.sublist(start, end);
  }

  static int _lowerBound<T>(
    List<T> sorted,
    int Function(T) compareToTarget,
    int low,
    int high,
  ) {
    if (low >= high) return low;
    final middle = low + (high - low) ~/ _halfDivisor;
    return compareToTarget(sorted[middle]) < 0
        ? _lowerBound(sorted, compareToTarget, middle + _nextStep, high)
        : _lowerBound(sorted, compareToTarget, low, middle);
  }

  // Primer índice desde index cuya clave ya no empieza con el prefijo.
  static int _prefixEnd<T>(
    List<T> sorted,
    int index,
    String prefix,
    String Function(T) keyOf,
  ) {
    final matches =
        index < sorted.length && keyOf(sorted[index]).startsWith(prefix);
    return matches
        ? _prefixEnd(sorted, index + _nextStep, prefix, keyOf)
        : index;
  }
}
