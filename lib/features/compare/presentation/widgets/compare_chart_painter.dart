import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';

/// Dibuja la gráfica neón vertical de una métrica: una columna por vehículo.
///
/// Cada columna sube desde la línea base con alto proporcional al valor (escala
/// común); arriba lleva el valor en blanco y debajo, la marca y el modelo. Una
/// línea ondeada pasa por la parte superior de cada columna, con trazo nítido,
/// halo difuso y un relleno de área que se desvanece hacia la base. El mejor
/// valor lleva el halo completo en su columna y su nodo; los demás, uno atenuado.
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

  /// Avance de la animación, de 0 a 1: columnas primero y línea después.
  final double progress;
  final TextScaler textScaler;

  static double _lineHeight(TextStyle style, TextScaler scaler) =>
      scaler.scale(style.fontSize!) * style.height!;

  /// Alto de la línea del valor con la escala de texto.
  static double valueLineHeight(TextScaler scaler) =>
      _lineHeight(AppTextStyles.compareChartValue, scaler).ceilToDouble();

  /// Alto de una línea de etiqueta con la escala de texto.
  static double labelLineHeight(TextScaler scaler) =>
      _lineHeight(AppTextStyles.compareChartLabel, scaler).ceilToDouble();

  /// Coordenada Y de la línea base.
  static double baseY(TextScaler scaler) =>
      CompareConfig.chartTopInset +
      valueLineHeight(scaler) +
      CompareConfig.chartValueGap +
      CompareConfig.chartNodeRadius +
      CompareConfig.chartPlotHeight;

  /// Alto total: valor, columnas y hasta dos líneas de etiqueta.
  static double totalHeight(TextScaler scaler) =>
      baseY(scaler) +
      CompareConfig.chartLabelTopGap +
      CompareConfig.chartLabelMaxLines * labelLineHeight(scaler);

  /// Centro horizontal del hueco del vehículo en [index] de [count].
  static double slotCenter(int index, int count, double width) =>
      width / count * (index + 0.5);

  /// Parte superior de cada columna con dato, de izquierda a derecha.
  ///
  /// Los vehículos sin dato no tienen punto. Es la geometría final, sin animar.
  static List<Offset> pointsOf(
    CompareChartMetricEntity metric,
    double width,
    TextScaler scaler,
  ) {
    final base = baseY(scaler);
    final max = metric.maxValue;
    final count = metric.bars.length;
    return [
      for (final (index, bar) in metric.bars.indexed)
        if (bar.value case final value?)
          Offset(
            slotCenter(index, count, width),
            base -
                (max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0) *
                    CompareConfig.chartPlotHeight,
          ),
    ];
  }

  // Tangente en cada punto: Catmull-Rom adentro y horizontal en los extremos.
  static Offset _tangent(List<Offset> points, int index) {
    if (index == 0) return Offset(points[1].dx - points[0].dx, 0);
    if (index == points.length - 1) {
      return Offset(points[index].dx - points[index - 1].dx, 0);
    }
    return (points[index + 1] - points[index - 1]) / 2;
  }

  // Un tramo cúbico entre dos puntos contiguos, sin pasarse de la altura de sus extremos.
  static List<(Offset, Offset, Offset)> _segments(List<Offset> points) {
    if (points.length < 2) return const [];
    const factor = CompareConfig.chartCurveTension / 3;
    return [
      for (final (i, a) in points.indexed)
        if (i < points.length - 1)
          () {
            final b = points[i + 1];
            final low = math.min(a.dy, b.dy);
            final high = math.max(a.dy, b.dy);
            final c1 = a + _tangent(points, i) * factor;
            final c2 = b - _tangent(points, i + 1) * factor;
            return (
              Offset(c1.dx, c1.dy.clamp(low, high)),
              Offset(c2.dx, c2.dy.clamp(low, high)),
              b,
            );
          }(),
    ];
  }

  /// Curva suave que pasa por todos los [points], de izquierda a derecha.
  static Path curvePath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    for (final (c1, c2, end) in _segments(points)) {
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
    }
    return path;
  }

  /// Distancia recorrida por la curva hasta cada punto (el primero es 0).
  static List<double> pointDistances(List<Offset> points) {
    if (points.isEmpty) return const [];
    final segments = _segments(points);
    final distances = <double>[0];
    for (final (i, (c1, c2, end)) in segments.indexed) {
      final start = points[i];
      final segment = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
      distances.add(distances.last + segment.computeMetrics().first.length);
    }
    return distances;
  }

  double get _columnProgress =>
      (progress / CompareConfig.chartColumnsEndFraction).clamp(0.0, 1.0);

  double get _lineProgress =>
      ((progress - CompareConfig.chartLineStartFraction) /
              (1 - CompareConfig.chartLineStartFraction))
          .clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final bars = metric.bars;
    if (bars.isEmpty) return;
    final base = baseY(textScaler);
    final slotWidth = size.width / bars.length;
    final columnWidth = math.min(
      CompareConfig.chartColumnMaxWidth,
      slotWidth * CompareConfig.chartColumnWidthFraction,
    );
    final points = pointsOf(metric, size.width, textScaler);

    // Línea base fina a lo largo de todo el ancho.
    canvas.drawLine(
      Offset(0, base),
      Offset(size.width, base),
      Paint()
        ..color = AppColors.chartAxis
        ..strokeWidth = CompareConfig.chartAxisWidth,
    );

    final line = _paintLine(canvas, points, base);

    // Posición de cada vehículo con dato dentro de la lista de puntos.
    final withData = [
      for (final (index, bar) in bars.indexed)
        if (bar.value != null) index,
    ];
    for (final (index, bar) in bars.indexed) {
      final bright = !metric.hasBest || bar.isBest;
      final center = slotCenter(index, bars.length, size.width);
      final value = bar.value;
      final pointIndex = withData.indexOf(index);
      final double textBottom;
      if (value != null) {
        final point = points[pointIndex];
        // La columna crece desde la base hasta el punto.
        final top = base - (base - point.dy) * _columnProgress;
        if (base - top >= 1) {
          _paintColumn(
            canvas,
            Rect.fromLTRB(
              center - columnWidth / 2,
              top,
              center + columnWidth / 2,
              base,
            ),
            bright,
          );
        }
        textBottom = top - CompareConfig.chartNodeRadius;
        // El nodo aparece cuando la línea llega a su punto.
        if (line != null && line.reached(pointIndex)) {
          _paintNode(canvas, point, bright);
        }
      } else {
        textBottom = base - CompareConfig.chartNodeRadius;
      }
      _paintValue(canvas, bar.valueText, center, textBottom, slotWidth);
      _paintLabel(
        canvas,
        names[bar.slotIndex],
        index * slotWidth + CompareConfig.chartLabelHorizontalInset,
        base + CompareConfig.chartLabelTopGap,
        slotWidth - 2 * CompareConfig.chartLabelHorizontalInset,
      );
    }
  }

  // Área, halo y trazo de la línea hasta donde llega la animación; nulo si aún no sale.
  _DrawnLine? _paintLine(Canvas canvas, List<Offset> points, double base) {
    if (points.length < 2 || _lineProgress <= 0) return null;
    final metrics = curvePath(points).computeMetrics().first;
    final reach = metrics.length * _lineProgress;
    final drawn = metrics.extractPath(0, reach);
    final head = metrics.getTangentForOffset(reach)?.position ?? points.last;

    // Relleno sutil que se desvanece hacia la línea base.
    final top = points.map((point) => point.dy).reduce(math.min);
    final area = Path.from(drawn)
      ..lineTo(head.dx, base)
      ..lineTo(points.first.dx, base)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, top), Offset(0, base), const [
          AppColors.chartNeonArea,
          AppColors.chartNeonAreaFade,
        ]),
    );

    // Dos capas de halo difuso y el trazo nítido encima.
    for (final sigma in [
      CompareConfig.chartGlowOuterSigma,
      CompareConfig.chartGlowInnerSigma,
    ]) {
      canvas.drawPath(
        drawn,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = CompareConfig.chartLineWidth * 2
          ..strokeCap = StrokeCap.round
          ..color = AppColors.chartNeonGlow
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, sigma),
      );
    }
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = CompareConfig.chartLineWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.chartNeon,
    );
    return _DrawnLine(reach, pointDistances(points));
  }

  // Halo ancho y halo cercano detrás de la columna, y encima el relleno nítido.
  void _paintColumn(Canvas canvas, Rect rect, bool bright) {
    final radius = Radius.circular(
      math.min(
        CompareConfig.chartColumnRadius,
        math.min(rect.width / 2, rect.height),
      ),
    );
    final glowColor = bright
        ? AppColors.chartNeonGlow
        : AppColors.chartNeonDimGlow;
    final glowRect = RRect.fromRectAndCorners(
      rect.inflate(CompareConfig.chartGlowSpread),
      topLeft: radius,
      topRight: radius,
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
      RRect.fromRectAndCorners(rect, topLeft: radius, topRight: radius),
      Paint()..color = bright ? AppColors.chartNeon : AppColors.chartNeonDim,
    );
  }

  // Nodo brillante: halo, disco neón y un núcleo claro.
  void _paintNode(Canvas canvas, Offset center, bool bright) {
    canvas.drawCircle(
      center,
      CompareConfig.chartNodeRadius + CompareConfig.chartGlowSpread,
      Paint()
        ..color = bright ? AppColors.chartNeonGlow : AppColors.chartNeonDimGlow
        ..maskFilter = const ui.MaskFilter.blur(
          ui.BlurStyle.normal,
          CompareConfig.chartNodeGlowSigma,
        ),
    );
    canvas.drawCircle(
      center,
      CompareConfig.chartNodeRadius,
      Paint()..color = bright ? AppColors.chartNeon : AppColors.chartNeonDim,
    );
    canvas.drawCircle(
      center,
      CompareConfig.chartNodeCoreRadius,
      Paint()..color = AppColors.onDark,
    );
  }

  // Valor con unidad, centrado sobre la columna y en blanco.
  void _paintValue(
    Canvas canvas,
    String text,
    double center,
    double bottom,
    double slotWidth,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTextStyles.compareChartValue),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
      ellipsis: AppTexts.ellipsis,
    )..layout(maxWidth: slotWidth);
    painter.paint(
      canvas,
      Offset(
        center - painter.width / 2,
        bottom - CompareConfig.chartValueGap - painter.height,
      ),
    );
  }

  // Marca y modelo bajo la base, centrados, hasta dos líneas con elipsis.
  void _paintLabel(
    Canvas canvas,
    String text,
    double left,
    double top,
    double width,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTextStyles.compareChartLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      textScaler: textScaler,
      maxLines: CompareConfig.chartLabelMaxLines,
      ellipsis: AppTexts.ellipsis,
    )..layout(minWidth: width, maxWidth: width);
    painter.paint(canvas, Offset(left, top));
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder =>
      (size) => [
        for (final (index, bar) in metric.bars.indexed)
          CustomPainterSemantics(
            rect: Rect.fromLTWH(
              size.width / metric.bars.length * index,
              0,
              size.width / metric.bars.length,
              size.height,
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

/// Hasta dónde llegó el trazo, para mostrar cada nodo cuando la línea lo alcanza.
class _DrawnLine {
  const _DrawnLine(this.reach, this.distances);

  final double reach;
  final List<double> distances;

  // Margen de un píxel: las longitudes por tramo y la total difieren en decimales.
  bool reached(int pointIndex) => reach + 1 >= distances[pointIndex];
}
