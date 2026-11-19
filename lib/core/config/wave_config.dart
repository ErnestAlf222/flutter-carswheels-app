/// Borde curvo de una ola: el superior o el inferior de la figura.
enum WaveEdge { top, bottom }

/// Forma de una ola: un solo tramo cúbico con puntos como fracciones.
///
/// Las x son fracciones del ancho; las y, fracciones de la amplitud (0 es el
/// punto más alto de la banda curva y 1 el más bajo).
class WaveShape {
  const WaveShape({
    required this.edge,
    required this.amplitude,
    required this.startY,
    required this.endY,
    required this.control1X,
    required this.control1Y,
    required this.control2X,
    required this.control2Y,
  });

  final WaveEdge edge;

  /// Alto de la banda curva, en píxeles lógicos.
  final double amplitude;
  final double startY;
  final double endY;
  final double control1X;
  final double control1Y;
  final double control2X;
  final double control2Y;

  @override
  bool operator ==(Object other) =>
      other is WaveShape &&
      other.edge == edge &&
      other.amplitude == amplitude &&
      other.startY == startY &&
      other.endY == endY &&
      other.control1X == control1X &&
      other.control1Y == control1Y &&
      other.control2X == control2X &&
      other.control2Y == control2Y;

  @override
  int get hashCode => Object.hash(
    edge,
    amplitude,
    startY,
    endY,
    control1X,
    control1Y,
    control2X,
    control2Y,
  );
}

/// Perfiles de las olas tinta: encabezados, pie del marco y pie de Detalle.
class WaveConfig {
  const WaveConfig._();

  // Encabezado: baja suave a la izquierda y cae más hacia la derecha.
  static const double headerAmplitude = 28.0;
  static const WaveShape headerWave = WaveShape(
    edge: WaveEdge.bottom,
    amplitude: headerAmplitude,
    startY: 0.2,
    endY: 0.9,
    control1X: 0.3,
    control1Y: 1.0,
    control2X: 0.7,
    control2Y: 0.0,
  );

  // Banda fija de Buscar: la misma curva con menos amplitud.
  static const double searchHeaderAmplitude = 12.0;
  static const WaveShape searchHeaderWave = WaveShape(
    edge: WaveEdge.bottom,
    amplitude: searchHeaderAmplitude,
    startY: 0.2,
    endY: 0.9,
    control1X: 0.3,
    control1Y: 1.0,
    control2X: 0.7,
    control2Y: 0.0,
  );

  // Pie del marco: alta a la izquierda y baja a la derecha.
  static const double footerAmplitude = 28.0;
  static const WaveShape footerWave = WaveShape(
    edge: WaveEdge.top,
    amplitude: footerAmplitude,
    startY: 0.1,
    endY: 1.0,
    control1X: 0.35,
    control1Y: 0.0,
    control2X: 0.65,
    control2Y: 1.0,
  );

  // Pie de Detalle: espejada respecto al pie del marco, con más amplitud.
  static const double detailFooterAmplitude = 36.0;
  static const WaveShape detailFooterWave = WaveShape(
    edge: WaveEdge.top,
    amplitude: detailFooterAmplitude,
    startY: 1.0,
    endY: 0.1,
    control1X: 0.35,
    control1Y: 1.0,
    control2X: 0.65,
    control2Y: 0.0,
  );
}
