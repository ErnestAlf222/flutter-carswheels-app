import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Un corazoncito de la ráfaga: dónde termina, qué tan grande y cuándo sale.
class FavoriteBurstParticle {
  const FavoriteBurstParticle({
    required this.driftX,
    required this.rise,
    required this.size,
    required this.delay,
    required this.sway,
  });

  /// Desplazamiento horizontal final, a izquierda (negativo) o derecha.
  final double driftX;

  /// Cuánto sube, en puntos.
  final double rise;
  final double size;

  /// Fracción inicial de la animación en que aún no aparece (0 a 0.3).
  final double delay;

  /// Amplitud del vaivén lateral mientras sube.
  final double sway;
}

/// Partículas de la ráfaga: siempre las mismas para una semilla dada.
List<FavoriteBurstParticle> favoriteBurstParticles({
  int count = FavoritesConfig.burstParticleCount,
  int seed = FavoritesConfig.burstSeed,
}) {
  final random = math.Random(seed);
  return List.generate(
    count,
    (index) => FavoriteBurstParticle(
      // Reparte las partículas en abanico de lado a lado.
      driftX:
          ((index + 0.5) / count * 2 - 1) * FavoritesConfig.burstSpread +
          (random.nextDouble() - 0.5) * FavoritesConfig.burstSpread * 0.4,
      rise:
          FavoritesConfig.burstRiseDistance * (0.6 + random.nextDouble() * 0.4),
      size:
          FavoritesConfig.burstMinSize +
          random.nextDouble() *
              (FavoritesConfig.burstMaxSize - FavoritesConfig.burstMinSize),
      delay: random.nextDouble() * 0.25,
      sway: (random.nextDouble() - 0.5) * FavoritesConfig.burstSpread * 0.5,
    ),
  );
}

/// Dibuja la ráfaga alrededor de su centro: corazones amarillos con contorno de tinta.
class FavoriteBurstPainter extends CustomPainter {
  FavoriteBurstPainter({required this.progress, required this.particles});

  /// Avance de la animación, de 0 a 1.
  final double progress;
  final List<FavoriteBurstParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = size.center(Offset.zero);
    for (final particle in particles) {
      final local = ((progress - particle.delay) / (1 - particle.delay)).clamp(
        0.0,
        1.0,
      );
      if (local <= 0) continue;
      final eased = Curves.easeOutCubic.transform(local);
      // Sube y se desvanece en el último tramo.
      final fade = local < FavoritesConfig.burstFadeStart
          ? 1.0
          : 1 -
                (local - FavoritesConfig.burstFadeStart) /
                    (1 - FavoritesConfig.burstFadeStart);
      final center = origin.translate(
        particle.driftX * eased + particle.sway * math.sin(local * math.pi),
        -particle.rise * eased,
      );
      // Crece al salir y queda a tamaño completo.
      final scale =
          particle.size * (0.4 + 0.6 * Curves.easeOut.transform(local));
      final path = _heart(center, scale);
      // El desvanecido va en una capa: el relleno amarillo conserva su color.
      canvas.saveLayer(
        null,
        Paint()..color = AppColors.ink.withValues(alpha: fade),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.accent
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = FavoritesConfig.burstOutlineWidth
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.restore();
    }
  }

  // Corazón de lado [size] centrado en [center].
  Path _heart(Offset center, double size) {
    final left = center.dx - size / 2;
    final top = center.dy - size / 2;
    double x(double f) => left + size * f;
    double y(double f) => top + size * f;
    return Path()
      ..moveTo(x(0.5), y(0.95))
      ..cubicTo(x(0.05), y(0.62), x(-0.02), y(0.25), x(0.22), y(0.12))
      ..cubicTo(x(0.38), y(0.04), x(0.5), y(0.16), x(0.5), y(0.28))
      ..cubicTo(x(0.5), y(0.16), x(0.62), y(0.04), x(0.78), y(0.12))
      ..cubicTo(x(1.02), y(0.25), x(0.95), y(0.62), x(0.5), y(0.95))
      ..close();
  }

  @override
  bool shouldRepaint(FavoriteBurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.particles != particles;
}
