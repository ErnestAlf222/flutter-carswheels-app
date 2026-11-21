import 'package:cars_wheels_app/core/config/animation_config.dart';

/// Medidas del carrusel de marcas.
class CarouselConfig {
  const CarouselConfig._();

  static const int visibleBrandCount = 4;
  // Fracción de una marca que asoma tras las completas.
  static const double peekFraction = 0.5;
  static const double brandTileSize = 72.0;
  static const double brandLogoSize = 50.0;
  // Ancho máximo de la etiqueta; sobra para que no se corte con la tarjeta.
  static const double brandLabelWidth = 76.0;
  // Flechas superpuestas: círculo visible, ícono, área táctil y margen al borde.
  static const double arrowButtonSize = 36.0;
  static const double arrowIconSize = 20.0;
  static const double arrowTouchTargetSize = 44.0;
  static const double arrowEdgeInset = 2.0;
  // Ancho del degradado que desvanece los logos en los bordes.
  static const double edgeFadeWidth = 36.0;
  static const double selectedRingWidth = 2.0;
  // Escala del logo de la marca activa (10 % más grande).
  static const double selectedScale = 1.1;
  // Margen vertical de la lista para que no recorte la sombra de las tarjetas.
  static const double shadowRoom = 20.0;
  // Desplazamiento de las flechas: una página de marcas, con su duración.
  static const int pageScrollMilliseconds =
      AnimationConfig.motionSlowMilliseconds;
  // Alto de línea del nombre bajo la marca, para reservar la altura de la fila.
  static const double brandNameLineHeightFactor = 1.6;
  // Máximo de logos que se precargan.
  static const int logoPrecacheMaxItems = 60;
  // Vueltas virtuales de margen a cada lado en los carruseles circulares.
  static const int circularPageBase = 1000;
}
