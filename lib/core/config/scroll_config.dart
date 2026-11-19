import 'package:flutter/animation.dart';

/// Botón de subir y memoria de la posición de scroll.
class ScrollConfig {
  const ScrollConfig._();

  // Botón circular traslúcido: tamaño, opacidad de la tinta y borde.
  static const double topButtonSize = 48.0;
  static const double topButtonIconSize = 24.0;
  static const double topButtonOpacity = 0.6;
  static const double topButtonBorderWidth = 0.5;
  // Márgenes: derecho y separación sobre la barra flotante de navegación.
  static const double topButtonRightMargin = 20.0;
  static const double topButtonNavGap = 12.0;
  // Botón flotante de filtros: apilado encima del de subir, mismo tamaño.
  static const double filterButtonSize = topButtonSize;
  static const double filterButtonIconSize = 24.0;
  static const double filterButtonStackGap = 12.0;
  // Hueco encima del botón de subir que ocupa el de filtros.
  static const double futureStackedButtonSlotHeight =
      filterButtonSize + filterButtonStackGap;

  // Desde cuántos píxeles de scroll aparece el botón.
  static const double topButtonShowThreshold = 400.0;
  static const int topButtonFadeMilliseconds = 200;
  static const int scrollToTopMilliseconds = 450;
  static const Curve scrollToTopCurve = Curves.easeInOutCubic;

  // Una sección guarda su posición mientras el mercado y el año no cambien.
  static const String homeSectionKey = 'home';
  static const String searchSectionKey = 'search';
}
