import 'package:flutter/animation.dart';

/// Curvas de animación de la app.
class AppCurves {
  const AppCurves._();

  // Rebote del menú flotante.
  static const Curve reboundCurve = Cubic(0.34, 1.56, 0.64, 1.0);

  // Crecimiento de las barras de la gráfica: sale rápido y se asienta.
  static const Curve chartGrowCurve = Curves.easeOutCubic;
}
