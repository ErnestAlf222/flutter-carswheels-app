/// Medidas y proporciones del encabezado oscuro y de la superposición de fotos.
class HeaderConfig {
  const HeaderConfig._();

  // Radio de las esquinas inferiores del encabezado y de la foto de Detalle.
  static const double bottomRadius = 32.0;
  // Relleno interno: arriba se suma al área segura.
  static const double contentTopPadding = 16.0;
  static const double contentBottomPadding = 24.0;
  // Resplandor amarillo: diámetro, desplazamiento fuera del borde y opacidad.
  static const double glowSize = 280.0;
  static const double glowOffset = -100.0;
  static const double glowOpacity = 0.30;
  // Superposición oscura de la foto de Detalle: opacidad arriba y abajo.
  static const double photoOverlayTopOpacity = 0.0;
  static const double photoOverlayBottomOpacity = 0.85;
  // Cuánto se superpone el panel claro de Detalle a la foto.
  static const double detailPanelOverlap = 28.0;
  // Mitad del alto de la barra de búsqueda: lo que sobresale del encabezado.
  static const double searchBarOverlap = 26.0;
  // Contraste mínimo de texto normal (WCAG AA) y de íconos (WCAG 1.4.11).
  static const double minContrastRatio = 4.5;
  static const double minIconContrastRatio = 3.0;
}
