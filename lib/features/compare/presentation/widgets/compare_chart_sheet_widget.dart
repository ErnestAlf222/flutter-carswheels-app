import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

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
  // Estado: la métrica elegida, si su explicación se ve y el temporizador que la cierra.
  int _selected = 0;
  bool _infoVisible = false;
  Timer? _infoTimer;

  @override
  void dispose() {
    _infoTimer?.cancel();
    super.dispose();
  }

  // Muestra la explicación y la descarta sola tras unos segundos.
  void _showInfo() {
    _infoTimer?.cancel();
    setState(() => _infoVisible = true);
    _infoTimer = Timer(
      const Duration(
        milliseconds: CompareConfig.metricInfoDurationMilliseconds,
      ),
      _hideInfo,
    );
  }

  void _hideInfo() {
    _infoTimer?.cancel();
    if (!mounted || !_infoVisible) return;
    setState(() => _infoVisible = false);
  }

  void _select(int index) {
    setState(() => _selected = index);
    _showInfo();
  }

  @override
  Widget build(BuildContext context) {
    final metric = widget.metrics[_selected];
    final still = MediaQuery.of(context).disableAnimations;
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
            Row(
              children: [
                Expanded(
                  child: _MetricSelector(
                    metrics: widget.metrics,
                    selected: _selected,
                    onSelected: _select,
                  ),
                ),
                _InfoButton(
                  active: _infoVisible,
                  onTap: _infoVisible ? _hideInfo : _showInfo,
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: still
                  ? Duration.zero
                  : const Duration(
                      milliseconds: CompareConfig.metricInfoEnterMilliseconds,
                    ),
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                alignment: Alignment.topCenter,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: _infoVisible
                  ? Padding(
                      key: ValueKey(metric.kind),
                      padding: const EdgeInsets.only(
                        top: CompareConfig.metricInfoGap,
                      ),
                      child: _InfoBubble(
                        text: _infoTextOf(metric.kind),
                        onDismiss: _hideInfo,
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('no-info')),
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

  // Qué mide cada métrica; unidad y sentido coinciden con la tabla.
  static String _infoTextOf(CompareRowKind kind) => switch (kind) {
    CompareRowKind.combinedConsumption => AppTexts.compareChartInfoConsumption,
    CompareRowKind.co2 => AppTexts.compareChartInfoCo2,
    CompareRowKind.annualCost => AppTexts.compareChartInfoAnnualCost,
    CompareRowKind.safety => AppTexts.compareChartInfoSafety,
    _ => '',
  };
}

/// Ícono pequeño de información: abre o cierra la explicación.
class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: active
          ? AppTexts.compareChartInfoCloseSemanticLabel
          : AppTexts.compareChartInfoOpenSemanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: CompareConfig.metricInfoTouchSize,
        height: CompareConfig.metricInfoTouchSize,
        child: InkWell(
          key: const ValueKey('compare-chart-info-button'),
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Icon(
            Symbols.info,
            fill: active ? 1.0 : 0.0,
            size: CompareConfig.metricInfoIconSize,
            color: AppColors.onDark,
          ),
        ),
      ),
    );
  }
}

/// Burbuja con la explicación; un toque la cierra.
class _InfoBubble extends StatelessWidget {
  const _InfoBubble({required this.text, required this.onDismiss});

  final String text;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(CompareConfig.metricInfoRadius);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Material(
        color: AppColors.inkSoft,
        borderRadius: radius,
        child: InkWell(
          key: const ValueKey('compare-chart-info-bubble'),
          onTap: onDismiss,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(CompareConfig.metricInfoPadding),
            child: Text(text, style: AppTextStyles.onDarkCaption),
          ),
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
