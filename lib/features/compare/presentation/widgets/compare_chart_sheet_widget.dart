import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_chart_painter.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_sheet_frame_widget.dart';

/// Abre la hoja oscura "Comparación visual" con las métricas dadas.
Future<void> showCompareChartSheet(
  BuildContext context, {
  required List<CompareChartMetricEntity> metrics,
  required List<String> names,
}) => showCompareSheet<void>(
  context,
  backgroundColor: AppColors.ink,
  maxHeightFraction: CompareConfig.chartSheetMaxHeightFraction,
  builder: (_) => CompareChartSheetWidget(metrics: metrics, names: names),
);

/// Selector de métrica y la gráfica neón de la elegida.
class CompareChartSheetWidget extends StatefulWidget {
  const CompareChartSheetWidget({
    super.key,
    required this.metrics,
    required this.names,
  });

  final List<CompareChartMetricEntity> metrics;

  /// Marca y modelo de cada vehículo, por su posición en la selección.
  final List<String> names;

  @override
  State<CompareChartSheetWidget> createState() =>
      _CompareChartSheetWidgetState();
}

class _CompareChartSheetWidgetState extends State<CompareChartSheetWidget> {
  // Único estado: la métrica elegida.
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final metric = widget.metrics[_selected];
    return CompareSheetFrameWidget(
      title: AppTexts.compareChartTitle,
      dark: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.xs,
          AppSpacing.l,
          AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MetricSelector(
              metrics: widget.metrics,
              selected: _selected,
              onSelected: (index) => setState(() => _selected = index),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              metric.lowerIsBetter
                  ? AppTexts.compareChartHintLower
                  : AppTexts.compareChartHintHigher,
              style: AppTextStyles.onDarkCaption,
            ),
            const SizedBox(height: AppSpacing.l),
            CompareChartWidget(metric: metric, names: widget.names),
          ],
        ),
      ),
    );
  }
}

/// Segmentos con las métricas disponibles; se desplazan si no caben.
class _MetricSelector extends StatelessWidget {
  const _MetricSelector({
    required this.metrics,
    required this.selected,
    required this.onSelected,
  });

  final List<CompareChartMetricEntity> metrics;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (index, metric) in metrics.indexed) ...[
            if (index > 0) const SizedBox(width: CompareConfig.chartSegmentGap),
            _Segment(
              label: metric.label,
              isSelected: index == selected,
              onTap: () => onSelected(index),
            ),
          ],
        ],
      ),
    );
  }
}

/// Un segmento: el elegido en blanco con texto tinta, los demás en tinta suave.
class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.pill);
    return Semantics(
      button: true,
      selected: isSelected,
      label: AppTexts.compareChartMetricSemanticLabel(label),
      excludeSemantics: true,
      child: Material(
        color: isSelected ? AppColors.onDark : AppColors.inkSoft,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: CompareConfig.chartSegmentHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CompareConfig.chartSegmentHorizontalPadding,
              ),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: isSelected ? AppColors.ink : AppColors.onDark,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// La gráfica de una métrica; columnas y línea se animan al abrir y al cambiar de métrica.
class CompareChartWidget extends StatelessWidget {
  const CompareChartWidget({
    super.key,
    required this.metric,
    required this.names,
  });

  final CompareChartMetricEntity metric;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final still = MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      // Otra métrica reinicia el crecimiento desde cero.
      key: ValueKey(metric.kind),
      tween: Tween<double>(begin: still ? 1.0 : 0.0, end: 1.0),
      duration: still
          ? Duration.zero
          : const Duration(milliseconds: CompareConfig.chartGrowMilliseconds),
      curve: AppCurves.chartGrowCurve,
      builder: (context, progress, _) => SizedBox(
        width: double.infinity,
        height: CompareChartPainter.totalHeight(scaler),
        child: CustomPaint(
          painter: CompareChartPainter(
            metric: metric,
            names: names,
            progress: progress,
            textScaler: scaler,
          ),
        ),
      ),
    );
  }
}
