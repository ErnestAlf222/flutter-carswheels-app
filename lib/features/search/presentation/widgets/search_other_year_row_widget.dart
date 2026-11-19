import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';

/// Fila compacta de un hallazgo en otro año: logo, grupo, marca y chip del año.
class SearchOtherYearRowWidget extends StatelessWidget {
  const SearchOtherYearRowWidget({
    super.key,
    required this.result,
    required this.onTap,
  });

  final SearchResultEntity result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final group = result.groupName ?? result.brand;
    final radius = BorderRadius.circular(AppRadii.card);
    return Semantics(
      button: true,
      label: AppTexts.searchOtherYearRowSemanticLabel(
        group,
        result.brand,
        result.year,
      ),
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox(
            height: SearchConfig.otherYearRowHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
              child: Row(
                children: [
                  Container(
                    width: SearchConfig.otherYearLogoCircleSize,
                    height: SearchConfig.otherYearLogoCircleSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: BrandLogoWidget(
                      brandName: result.brand,
                      size: SearchConfig.otherYearLogoSize,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyStrong,
                        ),
                        Text(
                          result.brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SearchConfig.chipHorizontalPadding,
                      vertical: SearchConfig.otherYearChipVerticalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(AppRadii.classChip),
                    ),
                    child: Text(
                      AppTexts.searchOtherYearChipLabel(result.year),
                      style: AppTextStyles.bodyStrong,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
