import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/domain/domain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Abre la hoja inferior para elegir una versión.
Future<void> showVersionSheet(
  BuildContext context, {
  required List<GroupVersionEntity> versions,
  required int selectedIndex,
  required ValueChanged<int> onSelected,
}) {
  final media = MediaQuery.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
    ),
    constraints: BoxConstraints(
      maxHeight: media.size.height * UiConfig.detailSheetMaxHeightFraction,
    ),
    sheetAnimationStyle: media.disableAnimations
        ? AnimationStyle.noAnimation
        : null,
    builder: (_) => VersionSheetWidget(
      versions: versions,
      selectedIndex: selectedIndex,
      onSelected: onSelected,
    ),
  );
}

/// Contenido de la hoja: asa, título y la lista de versiones.
class VersionSheetWidget extends StatelessWidget {
  const VersionSheetWidget({
    super.key,
    required this.versions,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<GroupVersionEntity> versions;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.s),
        Center(
          child: Container(
            width: UiConfig.detailSheetHandleWidth,
            height: UiConfig.detailSheetHandleHeight,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(
                UiConfig.detailSheetHandleHeight,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Text(
            AppTexts.versionSheetTitle,
            style: AppTextStyles.sectionTitle,
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: versions.length,
            itemBuilder: (context, index) => _VersionRow(
              version: versions[index],
              isSelected: index == selectedIndex,
              onTap: () {
                onSelected(index);
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Una versión de la lista con su descriptor, variante y consumo.
class _VersionRow extends StatelessWidget {
  const _VersionRow({
    required this.version,
    required this.isSelected,
    required this.onTap,
  });

  final GroupVersionEntity version;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final descriptor = context.read<VersionDescriptorBuilder>().describe(
      version.detail,
    );
    final title = descriptor.isEmpty ? version.variantName : descriptor;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title, ${version.variantName}',
      excludeSemantics: true,
      child: Material(
        color: isSelected ? AppColors.tint : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: CarouselConfig.arrowTouchTargetSize,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.bodyStrong),
                        Text(
                          version.variantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  _Consumption(detail: version.detail),
                  if (isSelected) ...[
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Symbols.check,
                      size: UiConfig.iconSize,
                      color: AppColors.link,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Consumo en km/l o, sin él, la etiqueta del tipo de motor.
class _Consumption extends StatelessWidget {
  const _Consumption({required this.detail});

  final VehicleDetailEntity detail;

  @override
  Widget build(BuildContext context) {
    final combined = detail.combinedKmPerLiter;
    if (combined != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppTexts.kmPerLiterFigure(combined),
            style: AppTextStyles.consumptionFigure,
          ),
          Text(AppTexts.kmPerLiterUnit, style: AppTextStyles.consumptionUnit),
        ],
      );
    }
    final labels = const PowertrainLabelsResolver().labelsForPowertrain(
      detail.powertrain,
    );
    return Text(
      labels.isEmpty
          ? AppTexts.noDataLabel
          : labels.join(AppTexts.semanticListSeparator),
      style: AppTextStyles.bodyStrong,
    );
  }
}
