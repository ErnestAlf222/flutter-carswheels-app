import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Sombras de la app.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 8)),
  ];
}
