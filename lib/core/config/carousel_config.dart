/// Medidas del carrusel de marcas.
class CarouselConfig {
  const CarouselConfig._();

  static const int visibleBrandCount = 4;
  static const double brandTileSize = 60.0;
  static const double brandLogoSize = 42.0;
  static const double arrowButtonSize = 32.0;
  static const double arrowIconSize = 18.0;
  static const double arrowTouchTargetSize = 48.0;
  static const double selectedRingWidth = 3.0;
  static const double yearSelectorHeight = 48.0;
  static const double yearTextMinWidth = 56.0;
  // Opacidad de una flecha deshabilitada.
  static const double disabledArrowOpacity = 0.4;
  // Fundido de la fila al mover la ventana de marcas.
  static const int shiftFadeMilliseconds = 150;
  // Máximo de logos que se precargan.
  static const int logoPrecacheMaxItems = 60;
}
