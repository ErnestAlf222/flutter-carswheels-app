/// Textos de orden, selección y comparación de la pantalla Favoritos.
class FavoritesTexts {
  const FavoritesTexts._();

  // Modo de selección y comparación desde favoritos.
  static const String selectAction = 'Seleccionar';
  static const String exitSelectionSemanticLabel = 'Salir de la selección';
  static const String otherMarketNote =
      'Solo puedes comparar autos del mismo mercado';
  static const String compareFullNote = 'Tu comparación está llena';
  static const String goToCompareAction = 'Ir a Comparar';
  static const String needTwoNote = 'La comparación necesita al menos 2 autos';
  static const String selectCarsHint = 'Elige los autos que quieras comparar';
  static String compareAction(int count) => 'Comparar ($count)';
  static String selectedCount(int count) =>
      count == 1 ? '1 seleccionado' : '$count seleccionados';
  static String capacityNote(int remaining) => remaining == 1
      ? 'Solo cabe 1 auto en tu comparación'
      : 'Solo caben $remaining autos en tu comparación';
  static String addedToCompare(int count) => count == 1
      ? 'Agregaste 1 auto a la comparación'
      : 'Agregaste $count autos a la comparación';
  static String selectCardSemanticLabel(String name, bool selected) =>
      selected ? 'Quitar $name de la selección' : 'Elegir $name para comparar';

  // Orden.
  static const String sortSemanticLabel = 'Ordenar favoritos';
  static const String sortRecent = 'Recientes';
  static const String sortAlphabetical = 'A–Z';
  static const String sortMostEfficient = 'Más eficiente';
}
