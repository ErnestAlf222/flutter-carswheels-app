/// Parámetros del catálogo.
class CatalogConfig {
  const CatalogConfig._();

  // Los valores son provisionales.
  static const int defaultPageSize = 10;
  static const int searchDebounceMilliseconds = 400;
  // Provisional: distancia al final del scroll que dispara la siguiente página.
  static const double loadMoreThresholdPixels = 240.0;
  // Aire de Inicio: sobre el título de Marcas y entre el carrusel y los modelos.
  static const double brandsHeaderTopPadding = 24.0;
  static const double modelsSectionTopGap = 8.0;
}
