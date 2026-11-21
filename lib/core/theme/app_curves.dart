import 'package:flutter/animation.dart';

import 'package:cars_wheels_app/core/theme/app_motion.dart';

/// Curvas de animación de la app.
class AppCurves {
  const AppCurves._();

  // Rebote del menú flotante.
  static const Curve reboundCurve = Cubic(0.34, 1.56, 0.64, 1.0);

  // Crecimiento de las barras de la gráfica: sale rápido y se asienta.
  static const Curve chartGrowCurve = AppMotion.enter;
}
