import 'package:flutter/rendering.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/widgets/wave_painter.dart';

/// Recorta con el mismo Path de la ola, para que el contenido siga su curva.
class WaveClipper extends CustomClipper<Path> {
  const WaveClipper(this.shape);

  final WaveShape shape;

  @override
  Path getClip(Size size) => WavePainter.pathFor(shape, size);

  @override
  bool shouldReclip(WaveClipper oldClipper) => shape != oldClipper.shape;
}
