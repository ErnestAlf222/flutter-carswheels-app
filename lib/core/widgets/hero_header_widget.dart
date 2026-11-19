import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';
import 'package:cars_wheels_app/core/widgets/wave_clipper.dart';
import 'package:cars_wheels_app/core/widgets/wave_painter.dart';

/// Encabezado tinta con borde inferior en ola y un resplandor neutro.
class HeroHeaderWidget extends StatelessWidget {
  const HeroHeaderWidget({
    super.key,
    required this.child,
    this.padding,
    this.shape = WaveConfig.headerWave,
  });

  final Widget child;

  /// Relleno interno; por defecto el área segura superior más el de config.
  final EdgeInsetsGeometry? padding;

  /// Curva del borde inferior; su amplitud se suma al alto del contenido.
  final WaveShape shape;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: WavePainter(shape: shape, color: AppColors.ink),
            ),
          ),
        ),
        // El resplandor se recorta con el mismo Path de la ola.
        Positioned.fill(
          child: ClipPath(
            clipper: WaveClipper(shape),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: HeaderConfig.glowOffset,
                  right: HeaderConfig.glowOffset,
                  child: ExcludeSemantics(
                    child: Container(
                      width: HeaderConfig.glowSize,
                      height: HeaderConfig.glowSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.headerGlow,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding:
              padding ??
              EdgeInsets.only(
                top: topInset + HeaderConfig.contentTopPadding,
                bottom: HeaderConfig.contentBottomPadding,
              ),
          // La banda curva va debajo del contenido: nunca lo toca.
          child: Padding(
            padding: EdgeInsets.only(bottom: shape.amplitude),
            child: child,
          ),
        ),
      ],
    );
  }
}
