import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_sheet_frame_widget.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_slot_visuals.dart';

/// Lo que se eligió en el menú de "Comparar" de un auto.
///
/// Con [replaced] es el vehículo de la comparación que se sustituye; sin él,
/// la persona quiere comparar con otro modelo.
class CompareActionChoice {
  const CompareActionChoice.substitute(CompareSlotEntity this.replaced);

  const CompareActionChoice.otherModel() : replaced = null;

  final CompareSlotEntity? replaced;
}

/// Abre el menú breve del auto que ya está o con la comparación llena.
///
/// Nulo si se cierra sin elegir. [alreadyAdded] distingue el título.
Future<CompareActionChoice?> showCompareActionsSheet(
  BuildContext context, {
  required List<CompareSlotEntity> current,
  required CompareSlotEntity incoming,
  required bool alreadyAdded,
  required CompareSlotVisuals visuals,
}) => showCompareSheet<CompareActionChoice>(
  context,
  builder: (_) => CompareActionsSheetWidget(
    current: current,
    incoming: incoming,
    alreadyAdded: alreadyAdded,
    visuals: visuals,
  ),
);

/// Una sola hoja con dos vistas: el menú de acciones y la lista a sustituir.
class CompareActionsSheetWidget extends StatefulWidget {
  const CompareActionsSheetWidget({
    super.key,
    required this.current,
    required this.incoming,
    required this.alreadyAdded,
    required this.visuals,
  });

  final List<CompareSlotEntity> current;
  final CompareSlotEntity incoming;
  final bool alreadyAdded;
  final CompareSlotVisuals visuals;

  @override
  State<CompareActionsSheetWidget> createState() =>
      _CompareActionsSheetWidgetState();
}

class _CompareActionsSheetWidgetState extends State<CompareActionsSheetWidget> {
  // Único estado: si se muestra la lista de autos a sustituir.
  bool _choosing = false;

  // Los que pueden sustituirse: todos menos el propio auto, si ya estaba.
  List<CompareSlotEntity> get _candidates => [
    for (final slot in widget.current)
      if (slot.identity != widget.incoming.identity) slot,
  ];

  @override
  Widget build(BuildContext context) {
    final incoming = widget.incoming;
    final name = AppTexts.compareColumnHeaderLabel(
      incoming.brand,
      incoming.modelName,
    );
    final bottom = MediaQuery.paddingOf(context).bottom;
    if (_choosing) {
      return CompareSheetFrameWidget(
        title: AppTexts.compareSubstituteTitle,
        subtitle: AppTexts.compareSubstituteBody(name),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: AppSpacing.xs,
            bottom: AppSpacing.xs + bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final slot in _candidates)
                _SlotRow(
                  slot: slot,
                  visuals: widget.visuals,
                  onTap: () =>
                      Navigator.of(context)
                          .pop(CompareActionChoice.substitute(slot)),
                ),
              TextButton(
                onPressed: () => setState(() => _choosing = false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mutedText,
                  minimumSize: const Size(0, CompareConfig.removeTouchSize),
                ),
                child: Text(
                  AppTexts.compareActionsBackLabel,
                  style: AppTextStyles.bodyStrong,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return CompareSheetFrameWidget(
      title: widget.alreadyAdded
          ? AppTexts.compareActionsAlreadyTitle(name)
          : AppTexts.compareActionsFullTitle,
      subtitle: AppTexts.compareActionsBody,
      child: Padding(
        padding: EdgeInsets.only(
          top: AppSpacing.xs,
          bottom: AppSpacing.m + bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_candidates.isNotEmpty)
              _ActionRow(
                icon: Symbols.swap_horiz,
                label: AppTexts.compareActionsSubstituteLabel,
                onTap: () => setState(() => _choosing = true),
              ),
            _ActionRow(
              icon: Symbols.search,
              label: AppTexts.compareActionsOtherModelLabel,
              onTap: () =>
                  Navigator.of(context)
                      .pop(const CompareActionChoice.otherModel()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Una acción del menú: ícono, texto y área táctil amplia.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: CompareConfig.actionRowMinHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Icon(icon, size: UiConfig.iconSize, color: AppColors.ink),
                const SizedBox(width: AppSpacing.s),
                Expanded(child: Text(label, style: AppTextStyles.bodyStrong)),
                const Icon(
                  Symbols.chevron_right,
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

/// Un vehículo actual: foto pequeña, marca, modelo, y su año con la bandera.
class _SlotRow extends StatelessWidget {
  const _SlotRow({
    required this.slot,
    required this.visuals,
    required this.onTap,
  });

  final CompareSlotEntity slot;
  final CompareSlotVisuals visuals;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final yearAndFlag = AppTexts.compareSubstituteYearFlag(
      slot.year,
      MarketConfig.flagOf(slot.marketCode),
    );
    return Semantics(
      button: true,
      label: AppTexts.compareSubstituteRowSemanticLabel(
        AppTexts.compareColumnHeaderLabel(slot.brand, slot.modelName),
        slot.year,
        AppTexts.marketLabelOf(slot.marketCode),
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
                        yearAndFlag,
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
