/// Elige la variante que representa a un grupo de modelos.
class RepresentativeVariantSelector {
  const RepresentativeVariantSelector();

  static const String _emptyMessage = 'No hay variantes para elegir';

  /// El nombre más corto; en empate, el primero de la lista.
  String select(List<String> variantNames) {
    if (variantNames.isEmpty) throw ArgumentError(_emptyMessage);
    return variantNames.reduce(
      (best, name) => name.length < best.length ? name : best,
    );
  }
}
