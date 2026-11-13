import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cars_wheels_app/core/theme/app_colors.dart';

/// Estilos de texto: Outfit para títulos y cifras, Inter para texto.
class AppTextStyles {
  const AppTextStyles._();

  static final TextStyle screenTitle = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 30,
    color: AppColors.ink,
  );
  static final TextStyle sectionTitle = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: AppColors.ink,
  );
  static final TextStyle cardTitle = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 19,
    color: AppColors.ink,
  );
  static final TextStyle figure = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 26,
    color: AppColors.ink,
  );
  static final TextStyle consumptionFigure = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: AppColors.gradientStart,
  );
  static final TextStyle consumptionUnit = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 11,
    color: AppColors.subtle,
  );
  static final TextStyle body = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: AppColors.ink,
  );
  static final TextStyle bodyStrong = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: AppColors.ink,
  );
  static final TextStyle caption = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.subtle,
  );
  static final TextStyle label = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    letterSpacing: 1.4,
    color: AppColors.ink,
  );
}
