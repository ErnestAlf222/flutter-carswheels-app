import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/domain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/vehicle_specs/presentation/widgets/summary_skeleton_bar_widget.dart';

/// Línea bajo el nombre del modelo con su clase y la cantidad de versiones.
class ModelClassLineWidget extends StatelessWidget {
  const ModelClassLineWidget({
    super.key,
    required this.brand,
    required this.groupName,
    required this.year,
    required this.versionsCount,
    this.translator = const VehicleClassTranslator(),
  });

  final String brand;
  final String groupName;
  final int year;
  final int versionsCount;
  final VehicleClassTranslator translator;

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
            alignment: Alignment.topLeft,
            children: [...previous, ?current],
          ),
          child: _line(slot),
        );
      },
    );
  }

  // Contenido según el espacio; la llave define cuándo hay fundido.
  Widget _line(SummarySlot? slot) {
    final versions = versionsCount > 1
        ? AppTexts.versionsCountLabel(versionsCount)
        : null;
    if (slot is SummaryLoading) {
      return Row(
        key: const ValueKey('loading'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const SummarySkeletonBarWidget(
            width: UiConfig.summarySkeletonLongBarWidth,
          ),
          if (versions != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Flexible(child: _caption(versions)),
          ],
        ],
      );
    }
    final vehicleClass = slot is SummaryFound
        ? translator.labelFor(slot.summary.vehicleClass)
        : null;
    final parts = <String>[?vehicleClass, ?versions];
    if (parts.isEmpty) return const SizedBox.shrink(key: ValueKey('empty'));
    return KeyedSubtree(
      key: ValueKey(parts.join()),
      child: _caption(parts.join(AppTexts.classAndVersionsSeparator)),
    );
  }

  Widget _caption(String text) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: AppTextStyles.caption,
  );
}
