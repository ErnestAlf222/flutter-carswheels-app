import 'package:flutter/painting.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Medidas de los espacios: el alto sale del ancho disponible y la escala de texto.
class CompareSlotMetrics {
  const CompareSlotMetrics._();

  /// Ancho de un espacio dado el ancho de la fila completa.
  static double slotWidth(double rowWidth) =>
      (rowWidth - CompareConfig.slotGap * (CompareConfig.maxSlots - 1)) /
      CompareConfig.maxSlots;

  static double photoHeight(double slotWidth) =>
      slotWidth / CompareConfig.slotPhotoAspectRatio;

  /// Alto del bloque de texto: marca con logo y hasta dos líneas del modelo.
  static double textHeight(TextScaler scaler) =>
      CompareConfig.slotTextPadding +
      _brandRowHeight(scaler) +
      CompareConfig.slotLogoGap +
      CompareConfig.slotNameMaxLines *
          _lineHeight(AppTextStyles.modelName, scaler) +
      CompareConfig.slotTextPadding;

  /// Alto de todo el espacio, ocupado o libre: ambos miden lo mismo.
  static double slotHeight(double slotWidth, TextScaler scaler) =>
      (photoHeight(slotWidth) + textHeight(scaler)).ceilToDouble();

  /// Alto de la banda fija de columnas: área segura, relleno, una línea y borde.
  static double bandHeight(TextScaler scaler, double topInset) =>
      topInset +
      2 * CompareConfig.bandVerticalPadding +
      _lineHeight(AppTextStyles.compareBandName, scaler).ceilToDouble() +
      CompareConfig.bandBorderWidth;

  static double _brandRowHeight(TextScaler scaler) {
    final text = _lineHeight(AppTextStyles.brandOverline, scaler);
    return text > CompareConfig.slotLogoSize
        ? text
        : CompareConfig.slotLogoSize;
  }

  // Alto de una línea del estilo con el tamaño de letra ya escalado.
  static double _lineHeight(TextStyle style, TextScaler scaler) =>
      scaler.scale(style.fontSize!) * style.height!;
}
