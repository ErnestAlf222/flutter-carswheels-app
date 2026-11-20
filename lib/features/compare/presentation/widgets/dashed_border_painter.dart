import 'package:flutter/rendering.dart';

/// Dibuja un borde redondeado de trazo discontinuo siguiendo un Path.
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    // El trazo queda dentro del recuadro: se encoge media línea.
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final border = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    for (final metric in border.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(
            distance,
            end > metric.length ? metric.length : end,
          ),
          paint,
        );
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      radius != oldDelegate.radius ||
      dashLength != oldDelegate.dashLength ||
      gapLength != oldDelegate.gapLength;
}
