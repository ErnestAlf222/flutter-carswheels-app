import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_empty_slot_widget.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_filled_slot_widget.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_slot_metrics.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_slot_visuals.dart';

/// Fila de [CompareConfig.maxSlots] espacios: primero los ocupados, luego los libres.
class CompareSlotsRowWidget extends StatelessWidget {
  const CompareSlotsRowWidget({
    super.key,
    required this.selection,
    required this.visuals,
    required this.onRemove,
    required this.onAdd,
    required this.onOpen,
  });

  final CompareSelectionEntity selection;
  final CompareSlotVisuals visuals;
  final ValueChanged<CompareSlotEntity> onRemove;
  final VoidCallback onAdd;
  final ValueChanged<CompareSlotEntity> onOpen;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = CompareSlotMetrics.slotWidth(constraints.maxWidth);
        final height = CompareSlotMetrics.slotHeight(width, scaler);
        return Row(
          children: [
            for (int index = 0; index < CompareConfig.maxSlots; index++) ...[
              if (index > 0) const SizedBox(width: CompareConfig.slotGap),
              SizedBox(
                width: width,
                height: height,
                child: index < selection.length
                    ? CompareFilledSlotWidget(
                        // La llave por identidad conserva la foto al quitar otro.
                        key: ValueKey(selection.slots[index].identity),
                        slot: selection.slots[index],
                        visuals: visuals,
                        onRemove: () => onRemove(selection.slots[index]),
                        onOpen: () => onOpen(selection.slots[index]),
                      )
                    : CompareEmptySlotWidget(onTap: onAdd),
              ),
            ],
          ],
        );
      },
    );
  }
}
