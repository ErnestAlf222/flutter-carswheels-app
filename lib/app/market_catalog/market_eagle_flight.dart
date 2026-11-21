import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/app/market_catalog/market_eagle_art.dart';
import 'package:cars_wheels_app/core/core.dart';

/// Posición y postura del águila en un instante del vuelo.
class EagleFlightPose {
  const EagleFlightPose({
    required this.center,
    required this.span,
    required this.roll,
    required this.squash,
    required this.flap,
  });

  /// Centro del cuerpo en la pantalla.
  final Offset center;

  /// Envergadura completa en dp.
  final double span;

  /// Inclinación en radianes y ancho relativo de frente (1 = completo).
  final double roll;
  final double squash;

  /// Aleteo: 0 con las alas arriba y 1 con las alas abajo.
  final double flap;
}

/// Coreografía: sale de lejos, se acerca, gira frente a la persona y se aleja.
class EagleFlight {
  const EagleFlight._();

  /// Postura en el avance [progress] (de 0 a 1) sobre una pantalla de [size].
  static EagleFlightPose poseAt(double progress, Size size) {
    final t = progress.clamp(0.0, 1.0);
    final maxSpan = math.min(
      MarketConfig.eagleMaxSpan,
      size.width * MarketConfig.eagleSpanScreenFraction,
    );
    final far = _point(MarketConfig.eagleFarPoint, size);
    final near = _point(MarketConfig.eagleNearPoint, size);
    final exit = _point(MarketConfig.eagleExitPoint, size);
    final Offset center;
    final double scale;
    final double roll;
    final double squash;
    if (t < MarketConfig.eagleApproachEnd) {
      final u = AppMotion.enter.transform(t / MarketConfig.eagleApproachEnd);
      center = Offset.lerp(far, near, u)!;
      scale = _lerp(MarketConfig.eagleFarScale, 1, u);
      roll = 0;
      squash = 1;
    } else if (t < MarketConfig.eagleTurnEnd) {
      final u =
          (t - MarketConfig.eagleApproachEnd) /
          (MarketConfig.eagleTurnEnd - MarketConfig.eagleApproachEnd);
      center = near;
      scale = 1;
      roll = MarketConfig.eagleRoll * AppMotion.change.transform(u);
      // Al girar, el ancho de frente se estrecha y se recupera.
      squash = math.cos(MarketConfig.eagleTurnAngle * math.sin(math.pi * u));
    } else {
      final u = Curves.easeInCubic.transform(
        (t - MarketConfig.eagleTurnEnd) / (1 - MarketConfig.eagleTurnEnd),
      );
      center = Offset.lerp(near, exit, u)!;
      scale = _lerp(1, MarketConfig.eagleExitScale, u);
      roll = MarketConfig.eagleRoll;
      squash = 1;
    }
    final bob =
        math.sin(2 * math.pi * t * MarketConfig.eagleFlapCycles) *
        MarketConfig.eagleBobAmplitude *
        scale;
    return EagleFlightPose(
      center: center + Offset(0, bob),
      span: maxSpan * scale,
      roll: roll,
      squash: squash,
      flap:
          0.5 - 0.5 * math.cos(2 * math.pi * t * MarketConfig.eagleFlapCycles),
    );
  }

  /// Opacidad del águila: plena, y se apaga al final de la salida.
  static double opacityAt(double progress) {
    final fade =
        (progress - MarketConfig.eagleFadeStart) /
        (1 - MarketConfig.eagleFadeStart);
    return (1 - fade).clamp(0.0, 1.0);
  }

  static Offset _point((double, double) fraction, Size size) =>
      Offset(fraction.$1 * size.width, fraction.$2 * size.height);

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}

/// Pinta el águila y su estela de destellos sobre el fondo transparente.
class MarketEagleFlightPainter extends CustomPainter {
  const MarketEagleFlightPainter({
    required this.palette,
    required this.progress,
  });

  final EaglePalette palette;

  /// Avance de todo el vuelo, de 0 a 1.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _paintTrail(canvas, size);
    final pose = EagleFlight.poseAt(progress, size);
    canvas
      ..save()
      ..translate(pose.center.dx, pose.center.dy)
      ..rotate(pose.roll)
      ..scale(pose.span / 2 * pose.squash, pose.span / 2);
    MarketEagleArt.paint(canvas, palette, pose.flap);
    canvas.restore();
  }

  // Destellos que quedan en el aire donde pasó el águila.
  void _paintTrail(Canvas canvas, Size size) {
    for (final index in Iterable<int>.generate(
      MarketConfig.trailSparkleCount,
    )) {
      final step = index + 1;
      final past = progress - step * MarketConfig.trailSparkleLag;
      if (past <= 0) continue;
      final pose = EagleFlight.poseAt(past, size);
      final life = 1 - step / (MarketConfig.trailSparkleCount + 1);
      final side = step.isEven ? 1.0 : -1.0;
      final center =
          pose.center +
          Offset(
            side * pose.span * MarketConfig.trailSparkleSpread,
            pose.span * MarketConfig.trailSparkleSpread * (step % 3 - 1),
          );
      final radius = pose.span * MarketConfig.trailSparkleSize * life;
      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(step * math.pi / 5);
      final path = _sparkle(radius);
      canvas
        ..drawPath(path, Paint()..color = AppColors.accent)
        ..drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = MarketConfig.trailSparkleOutlineWidth
            ..color = AppColors.ink,
        )
        ..restore();
    }
  }

  // Destello de cuatro puntas con lados cóncavos.
  Path _sparkle(double radius) {
    final k = radius * 0.15;
    return Path()
      ..moveTo(0, -radius)
      ..quadraticBezierTo(k, -k, radius, 0)
      ..quadraticBezierTo(k, k, 0, radius)
      ..quadraticBezierTo(-k, k, -radius, 0)
      ..quadraticBezierTo(-k, -k, 0, -radius)
      ..close();
  }

  @override
  bool shouldRepaint(MarketEagleFlightPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}
