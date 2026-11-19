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
}
