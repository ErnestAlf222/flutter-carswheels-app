import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cars_wheels_app/core/theme/app_colors.dart';
import 'package:cars_wheels_app/core/theme/app_text_styles.dart';

/// Tema claro de la app.
class AppTheme {
  const AppTheme._();

  // Íconos claros de la barra de estado sobre la banda tinta.
  static const SystemUiOverlayStyle lightStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  // Esquema neutro de la paleta; sin tinte de superficie de Material 3.
  static const ColorScheme _colorScheme = ColorScheme.light(
    primary: AppColors.ink,
    onPrimary: AppColors.onDark,
    secondary: AppColors.accent,
    onSecondary: AppColors.ink,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    outline: AppColors.outline,
    surfaceTint: Colors.transparent,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.surface,
    surfaceContainer: AppColors.surface,
    surfaceContainerHigh: AppColors.surface,
    surfaceContainerHighest: AppColors.surface,
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    // Ninguna superficie elevada toma un matiz del color primario.
    cardTheme: const CardThemeData(surfaceTintColor: Colors.transparent),
    bottomSheetTheme: const BottomSheetThemeData(
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: const DialogThemeData(surfaceTintColor: Colors.transparent),
    popupMenuTheme: const PopupMenuThemeData(
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(surfaceTintColor: Colors.transparent),
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
