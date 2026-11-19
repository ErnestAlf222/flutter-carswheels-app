import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';

/// Accesos rápidos a las marcas con más grupos del índice.
class SearchQuickBrandsWidget extends StatelessWidget {
  const SearchQuickBrandsWidget({
    super.key,
    required this.brands,
    required this.onSelect,
  });

  final List<String> brands;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.searchQuickBrandsTitle,
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: AppSpacing.s),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final brand in brands)
              _QuickBrandChip(
                key: ValueKey(brand),
                brand: brand,
                onTap: () => onSelect(brand),
              ),
          ],
        ),
      ],
    );
  }
}

class _QuickBrandChip extends StatelessWidget {
  const _QuickBrandChip({super.key, required this.brand, required this.onTap});

  final String brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppTexts.searchQuickBrandSemanticLabel(brand),
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SearchConfig.chipHorizontalPadding,
              vertical: SearchConfig.chipVerticalPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.chip),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandLogoWidget(
                  brandName: brand,
                  size: SearchConfig.quickBrandLogoSize,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(brand, style: AppTextStyles.bodyStrong),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
