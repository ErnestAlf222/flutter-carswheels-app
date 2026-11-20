import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Ilustración del estado vacío: un corazón de trazo fino con un auto y un destello.
class FavoritesEmptyPainter extends CustomPainter {
  const FavoritesEmptyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.mutedText
      ..style = PaintingStyle.stroke
      ..strokeWidth = FavoritesConfig.emptyStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;

    // Corazón: dos arcos que bajan a la punta.
    final heart = Path()
      ..moveTo(w * 0.5, h * 0.9)
      ..cubicTo(w * 0.1, h * 0.62, w * 0.02, h * 0.3, w * 0.24, h * 0.16)
      ..cubicTo(w * 0.38, h * 0.08, w * 0.5, h * 0.2, w * 0.5, h * 0.3)
      ..cubicTo(w * 0.5, h * 0.2, w * 0.62, h * 0.08, w * 0.76, h * 0.16)
      ..cubicTo(w * 0.98, h * 0.3, w * 0.9, h * 0.62, w * 0.5, h * 0.9);
    canvas.drawPath(heart, stroke);

    // Auto estilizado dentro del corazón: carrocería, techo y dos ruedas.
    final body = Path()
      ..moveTo(w * 0.28, h * 0.56)
      ..lineTo(w * 0.72, h * 0.56)
      ..lineTo(w * 0.7, h * 0.48)
      ..lineTo(w * 0.6, h * 0.44)
      ..lineTo(w * 0.42, h * 0.44)
      ..lineTo(w * 0.34, h * 0.5)
      ..close();
    canvas.drawPath(body, stroke);
    final wheel = w * 0.045;
    canvas.drawCircle(Offset(w * 0.38, h * 0.57), wheel, stroke);
    canvas.drawCircle(Offset(w * 0.62, h * 0.57), wheel, stroke);

    // Destello de cuatro puntas arriba a la derecha.
    final center = Offset(w * 0.86, h * 0.12);
    final arm = w * 0.07;
    canvas.drawLine(
      center.translate(0, -arm),
      center.translate(0, arm),
      stroke,
    );
    canvas.drawLine(
      center.translate(-arm, 0),
      center.translate(arm, 0),
      stroke,
    );
  }

  @override
  bool shouldRepaint(FavoritesEmptyPainter oldDelegate) => false;
}
