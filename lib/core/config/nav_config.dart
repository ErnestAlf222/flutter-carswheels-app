import 'package:cars_wheels_app/core/config/wave_config.dart';

/// Medidas y tiempos del menú flotante.
class NavConfig {
  const NavConfig._();

  // Círculo de cada ítem, separación, relleno y borde fino de la píldora.
  static const double buttonSize = 48.0;
  static const double buttonGap = 6.0;
  static const double pillPadding = 8.0;
  static const double pillBorderWidth = 1.0;
  static const double pillHeight =
      buttonSize + 2 * (pillPadding + pillBorderWidth);
  static const double bottomMargin = 24.0;
  // Espacio que ocupa el menú desde el borde inferior, sin el área segura.
  static const double footprint = bottomMargin + pillHeight;

  // Alto de la ola del marco: menú, área segura y la amplitud de la curva.
  static double waveFootprint(double safeBottom) =>
      footprint + safeBottom + WaveConfig.footerAmplitude;
  static const double hideOffsetY = 130.0;
  static const double hideScale = 0.8;
  static const int hideDurationMilliseconds = 550;
  static const int hideFadeMilliseconds = 350;
  static const int reappearDelayMilliseconds = 450;
  static const double scrollDeltaThreshold = 2.0;
}
