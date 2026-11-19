/// Parámetros de la búsqueda en memoria y de las búsquedas recientes.
class SearchConfig {
  const SearchConfig._();

  // Caracteres normalizados mínimos para buscar o guardar una búsqueda.
  static const int minQueryLength = 2;

  // Tope de resultados que devuelve una búsqueda.
  static const int maxResults = 50;

  // Marcas cuyos grupos se piden a la vez al construir el índice.
  static const int indexBuildConcurrency = 4;

  // Búsquedas recientes guardadas.
  static const int maxRecentSearches = 8;

  // Separador de mercado y año en la clave del índice.
  static const String scopeKeySeparator = '|';

  // Separa las partes de un nombre con guion (F-150 → F, 150).
  static const String tokenHyphen = '-';

  // Separador de las partes de la clave de orden; va antes que cualquier letra.
  static const String sortKeySeparator = '\u0000';

  // Nivel de orden: menor va primero.
  static const int exactGroupLevel = 0;
  static const int prefixGroupLevel = 1;
  static const int brandLevel = 2;

  // Mensaje técnico cuando una construcción se cancela.
  static const String buildCancelledMessage =
      'La construcción del índice fue cancelada';

  // Prefijo de la etiqueta de transición de Detalle abierto desde la búsqueda.
  static const String detailHeroTagPrefix = 'search';

  // Espera tras la última tecla antes de buscar.
  static const int debounceMilliseconds = 300;

  // Filas de resultados con animación de entrada escalonada.
  static const int animatedResultCount = 8;

  // Encabezado compacto: alto de la fila del título; el campo sobresale la mitad de su alto.
  static const double headerTitleRowHeight = 40.0;
  static const double fieldHeight = 56.0;
  static const double fieldOverlap = fieldHeight / 2;
  static const double fieldIconSize = 22.0;
  static const double progressHeight = 3.0;
  static const double chipHorizontalPadding = 12.0;
  static const double chipVerticalPadding = 6.0;

  // Selector de marcas: círculo con logo y etiqueta debajo.
  static const double brandCircleSize = 56.0;
  static const double brandLogoSize = 34.0;
  static const double brandItemWidth = 68.0;
  static const double brandItemGap = 4.0;
  static const double brandLabelHeight = 16.0;
  static const double brandRowVerticalPadding = 10.0;
  static const double brandRingWidth = 2.0;
  static const double brandRowHeight =
      brandRowVerticalPadding * 2 +
      brandCircleSize +
      brandItemGap +
      brandLabelHeight;

  // Recientes: una fila horizontal de chips.
  static const double recentChipHeight = 40.0;
  static const double recentChipGap = 8.0;
  static const double recentChipMaxWidth = 220.0;
  static const double recentRemoveSize = 28.0;
  static const double recentIconSize = 18.0;
  static const double recentRemoveIconSize = 16.0;

  // Estados vacíos.
  static const double idleIconSize = 72.0;
  static const double idleIconOpacity = 0.35;
  static const double emptyIconSize = 40.0;
  static const double sectionGap = 20.0;

  // Barra de búsqueda de la pantalla de inicio.
  static const double homeBarHeight = 52.0;
}
