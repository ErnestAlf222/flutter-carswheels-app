/// Parámetros del catálogo.
class CatalogConfig {
  const CatalogConfig._();

  // Los valores son provisionales.
  static const int defaultPageSize = 10;
  static const int searchDebounceMilliseconds = 400;
  // Provisional: distancia al final del scroll que dispara la siguiente página.
  static const double loadMoreThresholdPixels = 240.0;
}
