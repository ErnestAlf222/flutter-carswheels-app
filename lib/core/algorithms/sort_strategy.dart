/// Contrato de una estrategia de ordenamiento.
abstract class SortStrategy<T> {
  /// Devuelve una lista NUEVA ordenada; no modifica la original.
  List<T> sort(List<T> items, Comparator<T> compare);
}
