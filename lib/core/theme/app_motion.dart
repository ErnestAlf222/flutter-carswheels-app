import 'dart:math' as math;

import 'package:flutter/animation.dart';

import 'package:cars_wheels_app/core/config/animation_config.dart';

/// Resorte suave que se asienta en 1; para elementos que "caen" en su lugar.
class SoftSpringCurve extends Curve {
  const SoftSpringCurve();

  @override
  double transformInternal(double t) =>
      1 -
      math.exp(-AnimationConfig.springDamping * t) *
          math.cos(2 * math.pi * AnimationConfig.springCycles * t);
}

/// Lenguaje de movimiento: duraciones y curvas con inercia.
class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(
    milliseconds: AnimationConfig.motionFastMilliseconds,
  );
  static const Duration medium = Duration(
    milliseconds: AnimationConfig.motionMediumMilliseconds,
  );
  static const Duration slow = Duration(
    milliseconds: AnimationConfig.motionSlowMilliseconds,
  );
  static const Duration celebration = Duration(
    milliseconds: AnimationConfig.motionCelebrationMilliseconds,
  );

  /// Entradas: arrancan rápido y se asientan.
  static const Curve enter = Curves.easeOutCubic;

  /// Cambios de estado: aceleran y frenan con suavidad.
  static const Curve change = Curves.easeInOutCubic;

  /// Elementos que caen en su lugar.
  static const Curve settle = SoftSpringCurve();

  /// Duración o cero si la persona pidió menos movimiento.
  static Duration of(Duration duration, {required bool reduced}) =>
      reduced ? Duration.zero : duration;
}
