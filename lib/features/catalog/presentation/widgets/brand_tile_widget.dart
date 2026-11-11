import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';

/// Tarjeta de una marca con su logo y su nombre.
class BrandTileWidget extends StatelessWidget {
  const BrandTileWidget({
    super.key,
    required this.brandName,
    required this.selected,
    required this.onTap,
  });

  final String brandName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: AppTexts.brandTileLabel(brandName),
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: CarouselConfig.brandTileSize,
              height: CarouselConfig.brandTileSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadii.tile),
                boxShadow: selected
                    ? [
                        AppShadows.selectedRing(
                          CarouselConfig.selectedRingWidth,
                        ),
                        ...AppShadows.accent,
                      ]
                    : AppShadows.soft,
              ),
              child: BrandLogoWidget(
                brandName: brandName,
                size: CarouselConfig.brandLogoSize,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              brandName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: selected
                  ? AppTextStyles.caption.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    )
                  : AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
