/// Lugar de una tarjeta en el mosaico: su columna y su distancia al borde superior.
typedef MasonrySlot = ({int column, double top});

/// Resultado del reparto: el lugar de cada tarjeta y el alto total del mosaico.
typedef MasonryResult = ({List<MasonrySlot> slots, double height});

/// Reparte tarjetas de alturas distintas en columnas, siempre en la más corta.
class MasonryLayout {
  const MasonryLayout._();

  /// Coloca cada alto, en orden, en la columna más corta; con empate, la primera.
  ///
  /// [spacing] separa las tarjetas de una columna entre sí.
  static MasonryResult place({
    required List<double> heights,
    required int columns,
    required double spacing,
  }) {
    final bottoms = List<double>.filled(columns, 0);
    final counts = List<int>.filled(columns, 0);
    final slots = <MasonrySlot>[];
    for (final height in heights) {
      final shortest = List<int>.generate(columns, (column) => column).reduce(
        (best, column) => bottoms[column] < bottoms[best] ? column : best,
      );
      final top = counts[shortest] == 0 ? 0.0 : bottoms[shortest] + spacing;
      slots.add((column: shortest, top: top));
      bottoms[shortest] = top + height;
      counts[shortest]++;
    }
    final tallest = bottoms.fold<double>(0, (a, b) => a > b ? a : b);
    return (slots: slots, height: tallest);
  }
}
