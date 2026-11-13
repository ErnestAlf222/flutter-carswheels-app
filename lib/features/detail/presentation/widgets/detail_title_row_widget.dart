import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Marca, año y nombre del modelo, con la cápsula de clase a la derecha.
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTexts.brandYearLabel(brand, year),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(color: AppColors.subtle),
                ),
                Text(
                  groupName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.detailTitle,
                ),
              ],
            ),
          ),
          if (label != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Flexible(child: _ClassChip(label: label)),
          ],
        ],
      ),
    );
  }
}

/// Cápsula con la clase del vehículo.
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
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(AppRadii.classChip),
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
