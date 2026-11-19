import 'package:flutter/painting.dart';

import 'package:cars_wheels_app/core/theme/app_colors.dart';

/// Sombras de la app.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 8)),
  ];

  // Sombra del encabezado fijo; solo se muestra al estar encogido.
  static const List<BoxShadow> headerBottom = [
    BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
  ];

  // Anillo sólido de tinta, sin desenfoque.
  static BoxShadow selectedRing(double width) =>
      BoxShadow(color: AppColors.ink, blurRadius: 0, spreadRadius: width);
}
