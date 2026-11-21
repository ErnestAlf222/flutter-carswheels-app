import 'package:flutter/painting.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Medidas de una celda de la cuadrícula; el alto sale del contenido y la escala de texto.
class ModelGridMetrics {
  const ModelGridMetrics._();

  /// Ancho de una celda dado el ancho disponible de la cuadrícula.
  static double cellWidth(double crossAxisExtent) =>
      (crossAxisExtent -
          ModelGridConfig.crossAxisSpacing * (ModelGridConfig.columns - 1)) /
      ModelGridConfig.columns;

  static double photoHeight(
    double cellWidth, [
    double aspectRatio = ModelGridConfig.photoAspectRatio,
  ]) => cellWidth / aspectRatio;

  static double nameHeight(TextScaler scaler) =>
      ModelGridConfig.nameMaxLines *
      _lineHeight(AppTextStyles.modelName, scaler);

  static double brandLabelHeight(TextScaler scaler) =>
      _lineHeight(AppTextStyles.brandOverline, scaler) +
      ModelGridConfig.brandLabelBottomGap;

  static double classHeight(TextScaler scaler) =>
      _lineHeight(AppTextStyles.modelClass, scaler);

  // Alto de la fila de la cifra; la barra de eficiencia va debajo.
  static double consumptionFigureHeight(TextScaler scaler) =>
      _lineHeight(AppTextStyles.gridConsumptionFigure, scaler);

  static double consumptionHeight(TextScaler scaler) =>
      consumptionFigureHeight(scaler) +
      ModelGridConfig.efficiencyBarTopGap +
      ModelGridConfig.efficiencyBarHeight;

  /// Alto de la fila de acción opcional con su separación superior.
  static const double actionRowTotalHeight =
      ModelGridConfig.actionTopGap + ModelGridConfig.actionRowHeight;

  /// Alto total de la celda para un ancho de celda y una escala de texto.
  static double cellHeight(
    double cellWidth,
    TextScaler scaler, {
    bool showBrandLabel = false,
    bool reserveActionRow = false,
    double photoAspectRatio = ModelGridConfig.photoAspectRatio,
  }) =>
      (photoHeight(cellWidth, photoAspectRatio) +
              (showBrandLabel ? brandLabelHeight(scaler) : 0) +
              ModelGridConfig.textTopPadding +
              nameHeight(scaler) +
              ModelGridConfig.classTopGap +
              classHeight(scaler) +
              ModelGridConfig.consumptionTopGap +
              consumptionHeight(scaler) +
              (reserveActionRow ? actionRowTotalHeight : 0) +
              ModelGridConfig.textBottomPadding)
          .ceilToDouble();

  // Alto de una línea del estilo con el tamaño de letra ya escalado.
  static double _lineHeight(TextStyle style, TextScaler scaler) =>
      scaler.scale(style.fontSize!) * style.height!;
}
