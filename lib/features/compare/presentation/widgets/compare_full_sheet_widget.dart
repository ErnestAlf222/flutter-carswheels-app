import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_sheet_frame_widget.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_slot_visuals.dart';

/// Lo que se eligió en la hoja de comparador lleno.
///
/// Con [replaced] es el vehículo a quitar; sin él, limpiar todo y agregar.
class CompareFullChoice {
  const CompareFullChoice.replace(CompareSlotEntity this.replaced);

  const CompareFullChoice.clearAll() : replaced = null;

  final CompareSlotEntity? replaced;
}

/// Abre la hoja "El comparador está lleno"; nula si se cancela.
Future<CompareFullChoice?> showCompareFullSheet(
  BuildContext context, {
  required List<CompareSlotEntity> current,
  required CompareSlotEntity incoming,
  required CompareSlotVisuals visuals,
}) => showCompareSheet<CompareFullChoice>(
  context,
  builder: (_) => CompareFullSheetWidget(
    current: current,
    incoming: incoming,
    visuals: visuals,
  ),
);

/// Los vehículos actuales como filas tocables para reemplazar, y dos salidas.
class CompareFullSheetWidget extends StatelessWidget {
  const CompareFullSheetWidget({
    super.key,
    required this.current,
    required this.incoming,
    required this.visuals,
  });

  final List<CompareSlotEntity> current;
  final CompareSlotEntity incoming;
  final CompareSlotVisuals visuals;

  @override
  Widget build(BuildContext context) {
    return CompareSheetFrameWidget(
      title: AppTexts.compareFullSheetTitle,
      subtitle: AppTexts.compareFullSheetBody(
        AppTexts.compareColumnHeaderLabel(incoming.brand, incoming.modelName),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: AppSpacing.xs,
          bottom: AppSpacing.xs + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final slot in current)
              _Row(
                slot: slot,
                visuals: visuals,
                onTap: () =>
                    Navigator.of(context).pop(CompareFullChoice.replace(slot)),
              ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(const CompareFullChoice.clearAll()),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.ink,
                minimumSize: const Size(0, CompareConfig.removeTouchSize),
              ),
              child: Text(
                AppTexts.compareFullSheetClearLabel,
                style: AppTextStyles.bodyStrong,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.mutedText,
                minimumSize: const Size(0, CompareConfig.removeTouchSize),
              ),
              child: Text(
                AppTexts.cancelLabel,
                style: AppTextStyles.bodyStrong,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un vehículo actual: foto pequeña, marca, modelo y versión.
class _Row extends StatelessWidget {
  const _Row({required this.slot, required this.visuals, required this.onTap});

  final CompareSlotEntity slot;
  final CompareSlotVisuals visuals;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final version = slot.versionKey ?? AppTexts.compareVersionDefaultLabel;
    return Semantics(
      button: true,
      label: AppTexts.compareFullRowSemanticLabel(
        AppTexts.compareColumnHeaderLabel(slot.brand, slot.modelName),
        version,
      ),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: CompareConfig.versionRowMinHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    CompareConfig.fullRowPhotoRadius,
                  ),
                  child: SizedBox(
                    width: CompareConfig.fullRowPhotoWidth,
                    height: CompareConfig.fullRowPhotoHeight,
                    child: ExcludeSemantics(
                      child: visuals.photoBuilder(context, slot),
                    ),
                  ),
                ),
                const SizedBox(width: CompareConfig.fullRowGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.brand.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.brandOverline,
                      ),
                      Text(
                        slot.modelName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyStrong,
                      ),
                      Text(
                        version,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Symbols.swap_horiz,
                  size: UiConfig.iconSize,
                  color: AppColors.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
