/// Medidas del carrusel de marcas.
class CarouselConfig {
  const CarouselConfig._();

  static const int visibleBrandCount = 4;
  static const double brandTileSize = 60.0;
  static const double brandLogoSize = 42.0;
  static const double arrowButtonSize = 32.0;
  static const double arrowIconSize = 18.0;
  static const double arrowTouchTargetSize = 48.0;
  static const double selectedRingWidth = 2.0;
  // Fundido de la fila al mover la ventana de marcas.
  static const int shiftFadeMilliseconds = 150;
  // Máximo de logos que se precargan.
  static const int logoPrecacheMaxItems = 60;
  // Vueltas virtuales de margen a cada lado en los carruseles circulares.
  static const int circularPageBase = 1000;
}
