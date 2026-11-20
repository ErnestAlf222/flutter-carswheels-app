import 'dart:math' as math;

/// Espera entre sondas: crece con cada intento hasta un tope.
class ReconnectBackoff {
  const ReconnectBackoff({
    required this.initialDelay,
    required this.maxDelay,
    required this.factor,
  });

  final Duration initialDelay;
  final Duration maxDelay;
  final double factor;

  /// Espera antes del intento [attempt], contado desde cero.
  Duration delayFor(int attempt) {
    final milliseconds =
        initialDelay.inMilliseconds * math.pow(factor, attempt);
    return Duration(
      milliseconds: math.min(milliseconds, maxDelay.inMilliseconds).round(),
    );
  }
}
