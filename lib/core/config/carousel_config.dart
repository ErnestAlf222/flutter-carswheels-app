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
  // Margen vertical de la lista para que no recorte la sombra de las tarjetas.
  static const double shadowRoom = 20.0;
  // Desplazamiento de las flechas: una página de marcas, con su duración.
  static const int pageScrollMilliseconds = 320;
  // Alto de línea del nombre bajo la marca, para reservar la altura de la fila.
  static const double brandNameLineHeightFactor = 1.6;
  // Máximo de logos que se precargan.
  static const int logoPrecacheMaxItems = 60;
  // Vueltas virtuales de margen a cada lado en los carruseles circulares.
  static const int circularPageBase = 1000;
}
