import 'package:flutter/animation.dart';

/// Tiempos de las animaciones.
class AnimationConfig {
  const AnimationConfig._();

  // Tokens de movimiento: rápida, media, lenta y celebración.
  static const int motionFastMilliseconds = 150;
  static const int motionMediumMilliseconds = 250;
  static const int motionSlowMilliseconds = 350;
  static const int motionCelebrationMilliseconds = 1400;
  // Resorte suave: amortiguación y vueltas; termina en 1 sin rebote visible de más.
  static const double springDamping = 6.0;
  static const double springCycles = 1.0;

  // Valores provisionales; las animaciones son sutiles.
  static const int fadeDurationMilliseconds = motionMediumMilliseconds;
  static const int entryDelayStepMilliseconds = 60;

  // Cascada de listas y rejillas: desfase por índice, tope y desplazamiento corto.
  static const int staggerStepMilliseconds = 45;
  static const int staggerMaxAnimatedItems = 8;
  static const double staggerOffsetPixels = 14.0;
  // Provisional.
  static const int pageTransitionMilliseconds = 300;
  static const int dimDurationMilliseconds = motionFastMilliseconds;
  // Despliegue del panel de años y giro del chevron.
  static const int yearPanelMilliseconds = 160;
  // Deslizamiento del disco amarillo del interruptor de mercado.
  static const int marketSwitchMilliseconds = 180;
  static const int skeletonPulseMilliseconds = 1200;
  // Carrito del loader: un recorrido completo por ciclo, con ease en bucle.
  static const int loaderCycleMilliseconds = 1600;
  static const Curve loaderCurve = Curves.easeInOut;
  // Rebote del encabezado fijo al volver a expandirse.
  static const int headerSnapMilliseconds = 320;
  // Fracciones del encogimiento en que el contenido expandido se desvanece.
  static const double headerContentFadeStart = 0.35;
  static const double headerContentFadeEnd = 0.75;
}
