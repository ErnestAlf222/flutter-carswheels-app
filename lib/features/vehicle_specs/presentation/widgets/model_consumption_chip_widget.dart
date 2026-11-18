import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/domain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/presentation/cubits/cubits.dart';

/// Chip de consumo que llena el alto que le den: cifra en grande y km/l solo en combustión.
class ModelConsumptionChipWidget extends StatelessWidget {
  const ModelConsumptionChipWidget({
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
        return AnimatedSwitcher(
          duration: duration,
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.centerLeft,
            children: [...previous, ?current],
          ),
          child: _content(slot),
        );
      },
    );
  }

  Widget _content(SummarySlot? slot) {
    if (slot == null || slot is SummaryLoading) {
      return const _LoadingChip(key: ValueKey('loading'));
    }
    final summary = slot is SummaryFound ? slot.summary : null;
    final min = summary?.minKmPerLiter;
    final max = summary?.maxKmPerLiter;
    if (min != null && max != null) {
      final figure = AppTexts.consumptionFigureLabel(min.round(), max.round());
      return _Chip(
        key: ValueKey('figure-$figure'),
        child: Text.rich(
          TextSpan(
            style: AppTextStyles.gridConsumptionUnit,
            children: [
              TextSpan(
                text: figure,
                style: AppTextStyles.gridConsumptionFigure,
              ),
              const TextSpan(text: ' ${AppTexts.consumptionUnitShortLabel}'),
              const TextSpan(text: ' ${AppTexts.consumptionCombinedLabel}'),
            ],
          ),
          maxLines: 1,
          softWrap: false,
        ),
      );
    }
    // Sin rango de combustión: etiquetas de motorización o "—", nunca km/l.
    final labels = summary == null
        ? const <String>[]
        : _labels.labelsFor(summary);
    final text = labels.isEmpty
        ? AppTexts.missingValueLabel
        : labels.join(AppTexts.semanticListSeparator);
    return _Chip(
      key: ValueKey('label-$text'),
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: labels.isEmpty
            ? AppTextStyles.gridConsumptionFigure
            : AppTextStyles.gridConsumptionUnit,
      ),
    );
  }
}

/// Fondo suave de acento; se ajusta al contenido sin partirlo en dos líneas.
class _Chip extends StatelessWidget {
  const _Chip({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.consumptionChipBackground,
              borderRadius: BorderRadius.circular(AppRadii.classChip),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ModelGridConfig.consumptionChipHorizontalPadding,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Barra de esqueleto del alto de la fila.
class _LoadingChip extends StatelessWidget {
  const _LoadingChip({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.centerLeft,
        child: SkeletonBarWidget(
          width: ModelGridConfig.skeletonConsumptionBarWidth,
          height: constraints.maxHeight,
        ),
      ),
    );
  }
}
