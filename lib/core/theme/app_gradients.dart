import 'package:flutter/painting.dart';

import 'package:cars_wheels_app/core/theme/app_colors.dart';

/// Degradados de la app.
class AppGradients {
  const AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );
}
