import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cars_wheels_app/core/theme/app_colors.dart';

/// Estilos de texto: Outfit en negritas para títulos y cifras, Inter para texto.
class AppTextStyles {
  const AppTextStyles._();

  static final TextStyle screenTitle = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );
  static final TextStyle sectionTitle = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 26,
    letterSpacing: -0.5,
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
    letterSpacing: -0.3,
    color: AppColors.ink,
  );
  static final TextStyle consumptionFigure = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    letterSpacing: -0.4,
    color: AppColors.ink,
  );
  static final TextStyle consumptionUnit = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 11,
    color: AppColors.mutedText,
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
    color: AppColors.mutedText,
  );
  static final TextStyle attributionNote = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 11,
    height: 1.4,
    color: AppColors.mutedText,
  );
  static final TextStyle modelName = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.2,
    color: AppColors.ink,
  );
  static final TextStyle modelClass = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.2,
    color: AppColors.mutedText,
  );
  static final TextStyle gridConsumptionFigure = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.0,
    letterSpacing: -0.4,
    color: AppColors.ink,
  );
  static final TextStyle gridConsumptionUnit = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 10,
    height: 1.2,
    color: AppColors.mutedText,
  );
  static final TextStyle gridConsumptionLabel = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.2,
    color: AppColors.ink,
  );
  static final TextStyle photoChipLabel = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 11,
    color: AppColors.onDark,
  );
  static final TextStyle photoViewerCredit = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.photoViewerCreditText,
  );
  static final TextStyle detailTitle = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 36,
    height: 1.05,
    letterSpacing: -0.9,
    color: AppColors.ink,
  );
  static final TextStyle classChipLabel = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 13,
    color: AppColors.ink,
  );
  static final TextStyle statFigure = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 30,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );
  static final TextStyle efficiencyFigure = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    letterSpacing: -0.4,
    color: AppColors.ink,
  );
  static final TextStyle infoLabel = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.mutedText,
  );
  static final TextStyle infoValue = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.ink,
  );
  static final TextStyle recallsValue = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.ink,
  );
  static final TextStyle recallBody = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.4,
    color: AppColors.ink,
  );
  // Overline: mayúsculas pequeñas con espaciado amplio (marca, año).
  static final TextStyle label = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 11,
    letterSpacing: 1.6,
    color: AppColors.mutedText,
  );
  static final TextStyle detailBrandYearLabel = label.copyWith(
    letterSpacing: 1.2,
  );

  // Textos sobre fondo oscuro: encabezado y barra compacta.
  static final TextStyle onDarkWordmark = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 30,
    letterSpacing: -0.6,
    color: AppColors.onDark,
  );
  static final TextStyle onDarkWordmarkAccent = onDarkWordmark.copyWith(
    color: AppColors.accent,
  );
  static final TextStyle onDarkCompactTitle = cardTitle.copyWith(
    color: AppColors.onDark,
  );
  static final TextStyle onDarkCaption = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: AppColors.mutedOnDark,
  );
}
