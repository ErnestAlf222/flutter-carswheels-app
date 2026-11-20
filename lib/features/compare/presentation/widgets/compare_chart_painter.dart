import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';

/// Dibuja las barras horizontales neón de una métrica, una por vehículo.
///
/// Cada fila lleva la etiqueta a la izquierda y el valor a la derecha, y debajo
/// la barra: trazo amarillo nítido con un halo difuso hecho con dos capas de
/// desenfoque. El mejor valor lleva el halo completo; los demás, uno atenuado.
class CompareChartPainter extends CustomPainter {
  const CompareChartPainter({
    required this.metric,
    required this.names,
    required this.progress,
    required this.textScaler,
  });

  final CompareChartMetricEntity metric;

  /// Nombre de cada vehículo, indexado por su posición en la selección.
  final List<String> names;

  /// Avance del crecimiento de las barras, de 0 a 1.
  final double progress;
  final TextScaler textScaler;

  /// Alto de la línea de etiqueta y valor con la escala de texto.
  static double labelLineHeight(TextScaler scaler) {
    final label = AppTextStyles.compareChartLabel;
    final value = AppTextStyles.compareChartValue;
    final labelHeight = scaler.scale(label.fontSize!) * label.height!;
    final valueHeight = scaler.scale(value.fontSize!) * value.height!;
    return (labelHeight > valueHeight ? labelHeight : valueHeight)
        .ceilToDouble();
  }

  /// Alto de una fila: línea de texto, separación y barra.
  static double rowHeight(TextScaler scaler) =>
      labelLineHeight(scaler) +
      CompareConfig.chartLabelBarGap +
      CompareConfig.chartBarHeight;

  /// Alto total para [rows] filas.
  static double totalHeight(int rows, TextScaler scaler) =>
      rows * rowHeight(scaler) + (rows - 1) * CompareConfig.chartRowGap;

  double _rowTop(int index) =>
      index * (rowHeight(textScaler) + CompareConfig.chartRowGap);

  Rect _barSlot(int index, double width) => Rect.fromLTWH(
    0,
    _rowTop(index) +
        labelLineHeight(textScaler) +
        CompareConfig.chartLabelBarGap,
    width,
    CompareConfig.chartBarHeight,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (metric.bars.isEmpty) return;
    final max = metric.maxValue;
    // Línea base fina a lo largo de todas las barras.
    canvas.drawLine(
      Offset(0, _barSlot(0, size.width).top),
      Offset(0, _barSlot(metric.bars.length - 1, size.width).bottom),
      Paint()
        ..color = AppColors.chartAxis
        ..strokeWidth = CompareConfig.chartAxisWidth,
    );
    for (final (index, bar) in metric.bars.indexed) {
      final bright = !metric.hasBest || bar.isBest;
      _paintTexts(canvas, size.width, index, bar);
      final value = bar.value;
      if (value == null || max <= 0 || value <= 0) continue;
      final slot = _barSlot(index, size.width);
      final length = slot.width * (value / max) * progress;
      if (length <= 0) continue;
      _paintBar(
        canvas,
        Rect.fromLTWH(slot.left, slot.top, length, slot.height),
        bright,
      );
    }
  }

  // Etiqueta del vehículo a la izquierda y valor a la derecha, en blanco.
  void _paintTexts(
    Canvas canvas,
    double width,
    int index,
    CompareChartBarEntity bar,
  ) {
    final value = TextPainter(
      text: TextSpan(
        text: bar.valueText,
        style: AppTextStyles.compareChartValue,
      ),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final label =
        TextPainter(
          text: TextSpan(
            text: names[bar.slotIndex],
            style: AppTextStyles.compareChartLabel,
          ),
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
          maxLines: 1,
          ellipsis: AppTexts.ellipsis,
        )..layout(
          maxWidth: (width - value.width - CompareConfig.chartValueGap).clamp(
            0.0,
            width,
          ),
        );
    final top = _rowTop(index);
    final line = labelLineHeight(textScaler);
    label.paint(canvas, Offset(0, top + (line - label.height) / 2));
    value.paint(
      canvas,
      Offset(width - value.width, top + (line - value.height) / 2),
    );
  }

  // Halo ancho y halo cercano detrás, y encima el trazo nítido.
  void _paintBar(Canvas canvas, Rect rect, bool bright) {
    final radius = Radius.circular(rect.height / 2);
    final glowColor = bright
        ? AppColors.chartNeonGlow
        : AppColors.chartNeonDimGlow;
    final glowRect = RRect.fromRectAndRadius(
      rect.inflate(CompareConfig.chartGlowSpread),
      radius,
    );
    for (final sigma in [
      CompareConfig.chartGlowOuterSigma,
      CompareConfig.chartGlowInnerSigma,
    ]) {
      canvas.drawRRect(
        glowRect,
        Paint()
          ..color = glowColor
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, sigma),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()..color = bright ? AppColors.chartNeon : AppColors.chartNeonDim,
    );
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder =>
      (size) => [
        for (final (index, bar) in metric.bars.indexed)
          CustomPainterSemantics(
            rect: Rect.fromLTWH(
              0,
              _rowTop(index),
              size.width,
              rowHeight(textScaler),
            ),
            properties: SemanticsProperties(
              label: AppTexts.compareChartBarSemanticLabel(
                names[bar.slotIndex],
                bar.valueText,
                isBest: bar.isBest,
              ),
              textDirection: TextDirection.ltr,
            ),
          ),
      ];

  @override
  bool shouldRepaint(CompareChartPainter oldDelegate) =>
      metric != oldDelegate.metric ||
      names != oldDelegate.names ||
      progress != oldDelegate.progress ||
      textScaler != oldDelegate.textScaler;

  @override
  bool shouldRebuildSemantics(CompareChartPainter oldDelegate) =>
      metric != oldDelegate.metric || names != oldDelegate.names;
}
