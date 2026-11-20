import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_slot_metrics.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_slot_visuals.dart';

/// Espacio ocupado: foto, logo y marca, modelo y una "x" para quitarlo.
class CompareFilledSlotWidget extends StatelessWidget {
  const CompareFilledSlotWidget({
    super.key,
    required this.slot,
    required this.visuals,
    required this.onRemove,
  });

  final CompareSlotEntity slot;
  final CompareSlotVisuals visuals;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(CompareConfig.slotRadius),
          border: const Border.fromBorderSide(
            BorderSide(
              color: AppColors.outline,
              width: UiConfig.cardBorderWidth,
            ),
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Semantics(
          container: true,
          label: '${slot.brand} ${slot.modelName}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: CompareSlotMetrics.photoHeight(constraints.maxWidth),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ExcludeSemantics(
                      child: visuals.photoBuilder(context, slot),
                    ),
                    Positioned(
                      top: CompareConfig.removeButtonInset,
                      right: CompareConfig.removeButtonInset,
                      child: _RemoveButton(
                        name: slot.modelName,
                        onTap: onRemove,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CompareConfig.slotTextPadding,
                    vertical: CompareConfig.slotTextPadding,
                  ),
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            visuals.logoBuilder(
                              context,
                              slot,
                              CompareConfig.slotLogoSize,
                            ),
                            const SizedBox(width: CompareConfig.slotLogoGap),
                            Expanded(
                              child: Text(
                                slot.brand.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.brandOverline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: CompareConfig.slotLogoGap),
                        Text(
                          slot.modelName,
                          maxLines: CompareConfig.slotNameMaxLines,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.modelName,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón circular traslúcido de la esquina de la foto; el área táctil es mayor.
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppTexts.compareRemoveSemanticLabel(name),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // Área táctil ampliada hacia dentro de la tarjeta, sin desbordarla.
        child: SizedBox(
          width: CompareConfig.removeTouchSize,
          height: CompareConfig.removeTouchSize,
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              width: CompareConfig.removeButtonSize,
              height: CompareConfig.removeButtonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.ink.withValues(
                  alpha: CompareConfig.removeButtonOpacity,
                ),
              ),
              child: const Icon(
                Symbols.close,
                size: CompareConfig.removeButtonIconSize,
                color: AppColors.onDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
