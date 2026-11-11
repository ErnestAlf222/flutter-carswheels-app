import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Tema claro de la app.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.screenTitle,
      titleLarge: AppTextStyles.sectionTitle,
      titleMedium: AppTextStyles.cardTitle,
      displaySmall: AppTextStyles.figure,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.body,
      titleSmall: AppTextStyles.bodyStrong,
      bodySmall: AppTextStyles.caption,
      labelSmall: AppTextStyles.label,
    ),
  );
}
