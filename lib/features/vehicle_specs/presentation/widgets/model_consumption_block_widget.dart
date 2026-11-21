import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/domain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/presentation/cubits/cubits.dart';

/// Bloque de consumo: tablero, cifra grande y barra de eficiencia; solo combustión lleva km/l.
class ModelConsumptionBlockWidget extends StatelessWidget {
  const ModelConsumptionBlockWidget({
    super.key,
    required this.brand,
    required this.groupName,
    required this.year,
  });

  final String brand;
  final String groupName;
  final int year;

  static const PowertrainLabelsResolver _labels = PowertrainLabelsResolver();

  /// Proporción de la barra: promedio del rango sobre el tope, entre 0 y 1.
  static double fillFraction(double min, double max) =>
      (((min + max) / 2) / ModelGridConfig.efficiencyBarMaxKmPerLiter).clamp(
        0.0,
        1.0,
      );

  @override
  Widget build(BuildContext context) {
    final key = context.read<SummariesCubit>().keyFor(brand, groupName, year);
    return BlocSelector<SummariesCubit, SummariesState, SummarySlot?>(
      selector: (state) => state.slots[key],
      builder: (context, slot) {
        final duration = MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : AppMotion.medium;
        return AnimatedSwitcher(
          duration: duration,
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topLeft,
            children: [...previous, ?current],
          ),
          child: _content(slot),
        );
      },
    );
  }

  Widget _content(SummarySlot? slot) {
    if (slot == null || slot is SummaryLoading) {
      return const _LoadingBlock(key: ValueKey('loading'));
    }
    final summary = slot is SummaryFound ? slot.summary : null;
    final min = summary?.minKmPerLiter;
    final max = summary?.maxKmPerLiter;
    if (min != null && max != null) {
      final figure = AppTexts.consumptionFigureLabel(min.round(), max.round());
      return _FigureBlock(
        key: ValueKey('figure-$figure'),
        figure: figure,
        fraction: fillFraction(min, max),
      );
    }
    // Sin rango de combustión: etiquetas de motorización o "—", nunca km/l ni barra.
    final labels = summary == null
        ? const <String>[]
        : _labels.labelsFor(summary);
    final text = labels.isEmpty
        ? AppTexts.missingValueLabel
        : labels.join(AppTexts.semanticListSeparator);
    return _LabelBlock(
      key: ValueKey('label-$text'),
      text: text,
      isMissing: labels.isEmpty,
    );
  }
}

// Alto de una línea de la cifra con la escala de texto actual.
double _figureHeight(TextScaler scaler) =>
    scaler.scale(AppTextStyles.gridConsumptionFigure.fontSize!) *
    AppTextStyles.gridConsumptionFigure.height!;

/// Ícono, cifra y unidad con la barra de eficiencia debajo.
class _FigureBlock extends StatelessWidget {
  const _FigureBlock({super.key, required this.figure, required this.fraction});

  final String figure;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return Semantics(
      label: '$figure ${AppTexts.consumptionUnitLabel}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _figureHeight(scaler),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                spacing: ModelGridConfig.consumptionIconGap,
                children: [
                  const Icon(
                    Symbols.speed,
                    size: ModelGridConfig.consumptionIconSize,
                    color: AppColors.ink,
                  ),
                  Text(
                    figure,
                    maxLines: 1,
                    softWrap: false,
                    style: AppTextStyles.gridConsumptionFigure,
                  ),
                  Text(
                    AppTexts.consumptionUnitShortLabel,
                    maxLines: 1,
                    softWrap: false,
                    style: AppTextStyles.gridConsumptionUnit,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: ModelGridConfig.efficiencyBarTopGap),
          _EfficiencyBar(fraction: fraction),
        ],
      ),
    );
  }
}

/// Barra delgada con extremos redondeados que se llena con suavidad.
class _EfficiencyBar extends StatelessWidget {
  const _EfficiencyBar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(
            milliseconds: ModelGridConfig.efficiencyBarFillMilliseconds,
          );
    final radius = BorderRadius.circular(ModelGridConfig.efficiencyBarHeight);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: ModelGridConfig.efficiencyBarHeight,
        width: double.infinity,
        child: ColoredBox(
          color: AppColors.outline,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: fraction),
            duration: duration,
            curve: AppMotion.enter,
            builder: (context, value, _) => Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: radius,
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

/// Etiqueta de motorización (EV, enchufable, hidrógeno) o "—", sin barra.
class _LabelBlock extends StatelessWidget {
  const _LabelBlock({super.key, required this.text, required this.isMissing});

  final String text;
  final bool isMissing;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: isMissing
            ? AppTextStyles.gridConsumptionFigure
            : AppTextStyles.gridConsumptionLabel,
      ),
    );
  }
}

/// Esqueleto con la misma estructura: cifra y barra.
class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBarWidget(
          width: ModelGridConfig.skeletonConsumptionBarWidth,
          height: _figureHeight(scaler),
        ),
        const SizedBox(height: ModelGridConfig.efficiencyBarTopGap),
        const SkeletonBarWidget(
          width:
              ModelGridConfig.skeletonConsumptionBarWidth *
              ModelGridConfig.skeletonEfficiencyBarFraction,
          height: ModelGridConfig.efficiencyBarHeight,
        ),
      ],
    );
  }
}
