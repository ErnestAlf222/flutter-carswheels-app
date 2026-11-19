import 'package:cars_wheels_app/core/config/market_config.dart';

/// Parámetros de la búsqueda en memoria y de las búsquedas recientes.
class SearchConfig {
  const SearchConfig._();

  // Caracteres normalizados mínimos para buscar o guardar una búsqueda.
  static const int minQueryLength = 2;

  // Tope de resultados que devuelve una búsqueda.
  static const int maxResults = 50;

  // Marcas cuyos grupos se piden a la vez al construir el índice.
  static const int indexBuildConcurrency = 4;

  // Marcas coincidentes que se muestran arriba de los resultados.
  static const int maxBrandMatches = 3;

  // Sugerencias "¿Quisiste decir?": cantidad, largo mínimo del token y distancia
  // máxima de edición (1 hasta el largo corto, 2 desde ahí).
  static const int maxSuggestions = 2;
  static const int suggestionMinTokenLength = 3;
  static const int suggestionShortTokenMaxLength = 5;
  static const int suggestionShortMaxDistance = 1;
  static const int suggestionLongMaxDistance = 2;

  // Otros años: cuántos años cercanos se indexan y tope de filas halladas.
  static const int otherYearsCount = 3;
  static const int maxOtherYearsResults = 30;

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
  static const double headerTitleRowHeight = MarketConfig.selectorHeight;
  static const double pinnedBandPadding =
      12.0; // Arriba y abajo del campo en la banda fija.
  static const double fieldHeight = 56.0;
  static const double fieldOverlap = fieldHeight / 2;
  static const double fieldIconSize = 22.0;
  static const double progressHeight = 3.0;
  static const double chipHorizontalPadding = 12.0;
  static const double chipVerticalPadding = 6.0;

  // Selector de marcas: círculo con logo y etiqueta debajo.
  static const double brandCircleSize = 56.0;
  static const double brandLogoSize = 34.0;
  static const double brandItemWidth = 76.0;
  static const double brandItemGap = 4.0;
  static const int brandLabelMaxLines = 2;
  static const double brandLabelHeight = 32.0;
  static const double brandRowVerticalPadding = 10.0;
  static const double brandRingWidth = 2.0;
  static const double brandRowHeight =
      brandRowVerticalPadding * 2 +
      brandCircleSize +
      brandItemGap +
      brandLabelHeight;

  // Alcance de marca: fila compacta "Buscando en [logo] Marca x" bajo el campo.
  static const double scopeRowHeight = 48.0;
  static const double scopeLogoCircleSize = 28.0;
  static const double scopeLogoSize = 20.0;
  static const double scopeCloseSize = 32.0;
  static const double scopeCloseIconSize = 18.0;

  // Secciones, sugerencias y otros años.
  static const double sectionTitleGap = 8.0;
  static const double suggestionChipGap = 8.0;
  static const double suggestionChipHeight = 40.0;
  static const double otherYearRowHeight = 64.0;
  static const double otherYearLogoCircleSize = 44.0;
  static const double otherYearLogoSize = 28.0;
  static const double otherYearRowGap = 8.0;
  static const double otherYearGroupGap = 20.0;
  static const double otherYearGroupHeaderGap = 4.0;
  static const double otherYearGroupLineThickness = 1.0;
  static const double otherYearGroupLineGap = 12.0;
  // Botón secundario "Buscar en otros años".
  static const double otherYearsButtonHeight = 44.0;
  static const double otherYearsButtonBorderWidth = 1.0;
  static const double otherYearsButtonIconSize = 18.0;
  static const double otherYearsButtonIconGap = 8.0;
  static const double emptyTopGap = 40.0;

  // Recientes: filas planas con línea inferior.
  static const double recentRowHeight = 52.0;
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
