import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/domain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/presentation/cubits/cubits.dart';

/// Columna derecha de la tarjeta con el rango de km/l del modelo.
class ModelConsumptionWidget extends StatelessWidget {
  const ModelConsumptionWidget({
    super.key,
    required this.brand,
    required this.groupName,
    required this.year,
  });

  final String brand;
  final String groupName;
  final int year;

  static const PowertrainLabelsResolver _labels = PowertrainLabelsResolver();

  @override
  Widget build(BuildContext context) {
    final key = context.read<SummariesCubit>().keyFor(brand, groupName, year);
    return BlocSelector<SummariesCubit, SummariesState, SummarySlot?>(
      selector: (state) => state.slots[key],
      builder: (context, slot) {
        final duration = MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(
                milliseconds: AnimationConfig.fadeDurationMilliseconds,
              );
        return SizedBox(
          width: UiConfig.modelConsumptionColumnWidth,
          child: AnimatedSwitcher(
            duration: duration,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.centerRight,
              children: [...previous, ?current],
            ),
            child: _content(slot),
          ),
        );
      },
    );
  }

  // Contenido según el espacio; la llave define cuándo hay fundido.
  Widget _content(SummarySlot? slot) {
    const nothing = SizedBox.shrink(key: ValueKey('none'));
    if (slot is SummaryLoading) {
      return const Column(
        key: ValueKey('loading'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SkeletonBarWidget(
            width: UiConfig.summarySkeletonLongBarWidth,
            height: UiConfig.summarySkeletonBarHeight,
          ),
          SizedBox(height: AppSpacing.xs),
          SkeletonBarWidget(
            width: UiConfig.summarySkeletonShortBarWidth,
            height: UiConfig.summarySkeletonBarHeight,
          ),
        ],
      );
    }
    if (slot is! SummaryFound) return nothing;
    final summary = slot.summary;
    final min = summary.minKmPerLiter;
    final max = summary.maxKmPerLiter;
    if (min != null && max != null) {
      return _Figure(
        key: const ValueKey('figure'),
        figure: AppTexts.consumptionFigureLabel(min.round(), max.round()),
        isMixed: _labels.hasAlternative(summary),
      );
    }
    final labels = _labels.labelsFor(summary);
    if (labels.isEmpty) return nothing;
    return Column(
      key: ValueKey(labels.join()),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final label in labels)
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: AppTextStyles.caption,
          ),
      ],
    );
  }
}

/// Cifra de consumo con su unidad y, si hay versiones eléctricas, un rayo.
class _Figure extends StatelessWidget {
  const _Figure({super.key, required this.figure, required this.isMixed});

  final String figure;
  final bool isMixed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(figure, maxLines: 1, style: AppTextStyles.consumptionFigure),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isMixed)
              Semantics(
                label: AppTexts.mixedPowertrainSemanticLabel,
                child: const Icon(
                  Symbols.bolt,
                  size: UiConfig.powertrainBadgeIconSize,
                  color: AppColors.subtle,
                ),
              ),
            Flexible(
              child: Text(
                AppTexts.consumptionUnitLabel,
                maxLines: 2,
                textAlign: TextAlign.right,
                style: AppTextStyles.consumptionUnit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
