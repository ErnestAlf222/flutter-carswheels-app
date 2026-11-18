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

  static double photoHeight(double cellWidth) =>
      cellWidth / ModelGridConfig.photoAspectRatio;

  static double nameHeight(TextScaler scaler) =>
      ModelGridConfig.nameMaxLines *
      _lineHeight(AppTextStyles.modelName, scaler);

  static double classHeight(TextScaler scaler) =>
      _lineHeight(AppTextStyles.modelClass, scaler);

  // Alto de la fila de la cifra; la barra de eficiencia va debajo.
  static double consumptionFigureHeight(TextScaler scaler) =>
      _lineHeight(AppTextStyles.gridConsumptionFigure, scaler);

  static double consumptionHeight(TextScaler scaler) =>
      consumptionFigureHeight(scaler) +
      ModelGridConfig.efficiencyBarTopGap +
      ModelGridConfig.efficiencyBarHeight;

  /// Alto total de la celda para un ancho de celda y una escala de texto.
  static double cellHeight(double cellWidth, TextScaler scaler) =>
      (photoHeight(cellWidth) +
              ModelGridConfig.textTopPadding +
              nameHeight(scaler) +
              ModelGridConfig.classTopGap +
              classHeight(scaler) +
              ModelGridConfig.consumptionTopGap +
              consumptionHeight(scaler) +
              ModelGridConfig.textBottomPadding)
          .ceilToDouble();

  // Alto de una línea del estilo con el tamaño de letra ya escalado.
  static double _lineHeight(TextStyle style, TextScaler scaler) =>
      scaler.scale(style.fontSize!) * style.height!;
}
