import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/dashed_border_painter.dart';

/// Espacio libre: tarjeta de borde punteado con un "+" que abre el selector.
class CompareEmptySlotWidget extends StatelessWidget {
  const CompareEmptySlotWidget({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(CompareConfig.slotRadius);
    return Semantics(
      button: true,
      label: AppTexts.compareEmptySlotSemanticLabel,
      excludeSemantics: true,
      child: CustomPaint(
        foregroundPainter: const DashedBorderPainter(
          color: AppColors.dashedLine,
          strokeWidth: CompareConfig.slotBorderWidth,
          radius: CompareConfig.slotRadius,
          dashLength: CompareConfig.dashLength,
          gapLength: CompareConfig.dashGap,
        ),
        child: Material(
          color: AppColors.surface,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: const Center(
              child: Icon(
                Symbols.add,
                size: CompareConfig.slotPlusSize,
                color: AppColors.mutedText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
