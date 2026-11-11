import 'package:flutter/painting.dart';

import 'package:cars_wheels_app/core/theme/app_colors.dart';

/// Sombras de la app.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 8)),
  ];

  // Sombra de acento: el color del degradado al 35% de opacidad.
  static final List<BoxShadow> accent = [
    BoxShadow(
      color: AppColors.gradientStart.withValues(alpha: 0.35),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  // Anillo sólido del color del degradado, sin desenfoque.
  static BoxShadow selectedRing(double width) => BoxShadow(
    color: AppColors.gradientStart,
    blurRadius: 0,
    spreadRadius: width,
  );
}
