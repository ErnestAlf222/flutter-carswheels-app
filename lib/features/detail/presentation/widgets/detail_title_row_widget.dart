import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Overline de marca y año, nombre del modelo y la cápsula de clase debajo.
class DetailTitleRowWidget extends StatelessWidget {
  const DetailTitleRowWidget({
    super.key,
    required this.brand,
    required this.year,
    required this.groupName,
    this.classLabel,
  });

  final String brand;
  final int year;
  final String groupName;
  final String? classLabel;

  @override
  Widget build(BuildContext context) {
    final label = classLabel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConfig.detailInfoSideMargin,
        AppSpacing.xs,
        UiConfig.detailInfoSideMargin,
        0,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTexts.brandYearLabel(brand, year).toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.detailBrandYearLabel,
            ),
            Text(
              groupName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.detailTitle,
            ),
            if (label != null) ...[
              const SizedBox(height: AppSpacing.xs),
              _ClassChip(label: label),
            ],
          ],
        ),
      ),
    );
  }
}

/// Píldora con borde suave con la clase del vehículo.
class _ClassChip extends StatelessWidget {
  const _ClassChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: UiConfig.detailChipVerticalPadding,
        horizontal: UiConfig.detailChipHorizontalPadding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.classChipLabel,
      ),
    );
  }
}
