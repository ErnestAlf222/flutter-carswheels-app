import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';

/// Fila compacta de un resultado: logo, nombre, marca y año, y chevron.
class SearchResultRowWidget extends StatelessWidget {
  const SearchResultRowWidget({
    super.key,
    required this.result,
    required this.onTap,
  });

  final SearchResultEntity result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final group = result.groupName;
    final title = group ?? result.brand;
    final subtitle = group == null
        ? AppTexts.searchBrandRowSubtitle
        : AppTexts.searchResultSubtitle(result.brand, result.year);
    final semanticLabel = group == null
        ? AppTexts.searchBrandRowSemanticLabel(result.brand, result.year)
        : AppTexts.searchGroupRowSemanticLabel(
            group,
            result.brand,
            result.year,
          );
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.tile),
          child: Container(
            height: SearchConfig.resultRowHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.tile),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                BrandLogoWidget(
                  brandName: result.brand,
                  size: SearchConfig.resultLogoSize,
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.modelName,
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.modelClass,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Symbols.chevron_right,
                  size: SearchConfig.fieldIconSize,
                  color: AppColors.subtle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
