/// Parámetros del catálogo.
class CatalogConfig {
  const CatalogConfig._();

  // Los tres valores son provisionales.
  static const int defaultPageSize = 10;
  static const int searchDebounceMilliseconds = 400;
  static const int cacheTimeToLiveDays = 7;
  // Provisional: distancia al final del scroll que dispara la siguiente página.
  static const double loadMoreThresholdPixels = 240.0;
}
