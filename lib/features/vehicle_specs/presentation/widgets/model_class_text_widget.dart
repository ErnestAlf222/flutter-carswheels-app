import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/domain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/presentation/cubits/cubits.dart';

/// Línea con la clase (o el combustible en México); "—" si no hay dato.
class ModelClassTextWidget extends StatelessWidget {
  const ModelClassTextWidget({
    super.key,
    required this.brand,
    required this.groupName,
    required this.year,
  });

  final String brand;
  final String groupName;
  final int year;

  @override
  Widget build(BuildContext context) {
    final key = context.read<SummariesCubit>().keyFor(brand, groupName, year);
    final translator = context.read<VehicleClassTranslator>();
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
            alignment: Alignment.topLeft,
            children: [...previous, ?current],
          ),
          child: _line(slot, translator),
        );
      },
    );
  }

  Widget _line(SummarySlot? slot, VehicleClassTranslator translator) {
    if (slot == null || slot is SummaryLoading) {
      return const Align(
        key: ValueKey('loading'),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: ModelGridConfig.skeletonClassBarFraction,
          child: SkeletonBarWidget(
            width: double.infinity,
            height: ModelGridConfig.skeletonClassBarHeight,
          ),
        ),
      );
    }
    // México no trae clase: en su lugar va el combustible.
    final label = slot is SummaryFound
        ? slot.summary.fuelLabel ??
              translator.labelFor(slot.summary.vehicleClass)
        : null;
    final text = label ?? AppTexts.missingValueLabel;
    return Align(
      key: ValueKey(text),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.modelClass,
      ),
    );
  }
}
