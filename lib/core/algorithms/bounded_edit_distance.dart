/// Distancia de Damerau–Levenshtein (alineación óptima de cadenas) con tope.
///
/// Cuenta inserciones, borrados, sustituciones y transposiciones adyacentes.
/// Devuelve nulo en cuanto la distancia supera [maxDistance], sin calcular el resto.
class BoundedEditDistance {
  const BoundedEditDistance._();

  /// Distancia entre [a] y [b] si es menor o igual que [maxDistance]; si no, nulo.
  static int? between(String a, String b, int maxDistance) {
    if (maxDistance < 0) return null;
    if ((a.length - b.length).abs() > maxDistance) return null;
    if (a == b) return 0;
    final n = a.length;
    final m = b.length;
    if (n == 0) return m;
    if (m == 0) return n;
    // Tres filas: la anterior a la anterior (para transponer), la anterior y la actual.
    List<int> twoBack = List.filled(m + 1, 0);
    List<int> previous = List.generate(m + 1, (j) => j);
    List<int> current = List.filled(m + 1, 0);
    for (int i = 1; i <= n; i++) {
      current[0] = i;
      int rowMin = current[0];
      for (int j = 1; j <= m; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        int best = previous[j - 1] + cost;
        final deletion = previous[j] + 1;
        final insertion = current[j - 1] + 1;
        if (deletion < best) best = deletion;
        if (insertion < best) best = insertion;
        final canSwap =
            i > 1 &&
            j > 1 &&
            a.codeUnitAt(i - 1) == b.codeUnitAt(j - 2) &&
            a.codeUnitAt(i - 2) == b.codeUnitAt(j - 1);
        if (canSwap && twoBack[j - 2] + 1 < best) best = twoBack[j - 2] + 1;
        current[j] = best;
        if (best < rowMin) rowMin = best;
      }
      // Ninguna celda de la fila está dentro del tope: ya no puede bajar.
      if (rowMin > maxDistance) return null;
      final recycled = twoBack;
      twoBack = previous;
      previous = current;
      current = recycled;
    }
    final result = previous[m];
    return result <= maxDistance ? result : null;
  }
}
