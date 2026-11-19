import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';
import 'package:cars_wheels_app/core/widgets/wave_painter.dart';

/// Ola tinta decorativa a todo el ancho; el hijo opcional va encima de ella.
class WaveFooterWidget extends StatelessWidget {
  const WaveFooterWidget({
    super.key,
    required this.shape,
    required this.height,
    this.child,
  });

  final WaveShape shape;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: WavePainter(shape: shape, color: AppColors.ink),
        child: SizedBox(width: double.infinity, height: height, child: child),
      ),
    );
  }
}
