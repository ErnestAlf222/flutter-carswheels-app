import 'package:flutter/rendering.dart';

import 'package:cars_wheels_app/core/config/config.dart';

/// Pinta una ola sólida con un Path armado desde su forma.
class WavePainter extends CustomPainter {
  const WavePainter({required this.shape, required this.color});

  final WaveShape shape;
  final Color color;

  /// Contorno de la ola dentro de un área; la banda curva ocupa la amplitud.
  static Path pathFor(WaveShape shape, Size size) {
    final width = size.width;
    final height = size.height;
    final path = Path();
    if (shape.edge == WaveEdge.bottom) {
      // Borde inferior curvo: la banda curva son los últimos píxeles.
      final top = height - shape.amplitude;
      double y(double fraction) => top + shape.amplitude * fraction;
      path
        ..moveTo(0, 0)
        ..lineTo(width, 0)
        ..lineTo(width, y(shape.endY))
        ..cubicTo(
          width * shape.control2X,
          y(shape.control2Y),
          width * shape.control1X,
          y(shape.control1Y),
          0,
          y(shape.startY),
        )
        ..close();
    } else {
      // Borde superior curvo: la banda curva son los primeros píxeles.
      double y(double fraction) => shape.amplitude * fraction;
      path
        ..moveTo(0, height)
        ..lineTo(0, y(shape.startY))
        ..cubicTo(
          width * shape.control1X,
          y(shape.control1Y),
          width * shape.control2X,
          y(shape.control2Y),
          width,
          y(shape.endY),
        )
        ..lineTo(width, height)
        ..close();
    }
    return path;
  }

  // Decorativa: no captura toques; los de sus hijos siguen funcionando.
  @override
  bool? hitTest(Offset position) => false;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(pathFor(shape, size), Paint()..color = color);
  }

  // Solo importan los parámetros: no hay estado oculto.
  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      shape != oldDelegate.shape || color != oldDelegate.color;
}
