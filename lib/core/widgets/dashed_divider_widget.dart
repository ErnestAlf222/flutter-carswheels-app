import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';

/// Línea horizontal punteada que ocupa todo el ancho disponible.
class DashedDividerWidget extends StatelessWidget {
  const DashedDividerWidget({super.key});

  static const double _thickness = 1;

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: _thickness,
      width: double.infinity,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

/// Pinta los trazos de la línea punteada.
class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.dashedLine
      ..strokeWidth = size.height;
    final y = size.height / 2;
    const step = UiConfig.dashedDashWidth + UiConfig.dashedGapWidth;
    for (double x = 0; x < size.width; x += step) {
      final end = (x + UiConfig.dashedDashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => false;
}
