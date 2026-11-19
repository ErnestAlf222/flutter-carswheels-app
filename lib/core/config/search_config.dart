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

  // Marcas de acceso rápido: las que más grupos tienen en el índice.
  static const int quickBrandCount = 8;

  // Filas de resultados con animación de entrada escalonada.
  static const int animatedResultCount = 8;

  // Medidas de la pantalla de búsqueda.
  static const double fieldHeight = 56.0;
  static const double fieldIconSize = 22.0;
  static const double progressHeight = 3.0;
  static const double resultRowHeight = 68.0;
  static const double resultLogoSize = 40.0;
  static const double recentRowHeight = 48.0;
  static const double quickBrandLogoSize = 24.0;
  static const double chipVerticalPadding = 6.0;
  static const double chipHorizontalPadding = 12.0;
  static const double sectionGap = 20.0;
  static const double emptyIconSize = 40.0;

  // Barra de búsqueda de la pantalla de inicio.
  static const double homeBarHeight = 52.0;
}
