/// Medidas y tiempos del menú flotante.
class NavConfig {
  const NavConfig._();

  // Círculo de cada ítem, separación y relleno de la píldora.
  static const double buttonSize = 48.0;
  static const double buttonGap = 6.0;
  static const double pillPadding = 8.0;
  static const double pillHeight = buttonSize + 2 * pillPadding;
  static const double bottomMargin = 24.0;
  // Espacio que ocupa el menú desde el borde inferior, sin el área segura.
  static const double footprint = bottomMargin + pillHeight;
  static const double hideOffsetY = 130.0;
  static const double hideScale = 0.8;
  static const int hideDurationMilliseconds = 550;
  static const int hideFadeMilliseconds = 350;
  static const int reappearDelayMilliseconds = 450;
  static const double scrollDeltaThreshold = 2.0;
}
