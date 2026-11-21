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
            // La escala no cambia el espacio que ocupa la ficha.
            AnimatedScale(
              scale: selected ? CarouselConfig.selectedScale : 1.0,
              duration: AppMotion.of(
                AppMotion.medium,
                reduced: MediaQuery.of(context).disableAnimations,
              ),
              curve: AppMotion.settle,
              child: Container(
                width: CarouselConfig.brandTileSize,
                height: CarouselConfig.brandTileSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.tile),
                  border: const Border.fromBorderSide(
                    BorderSide(
                      color: AppColors.outline,
                      width: UiConfig.cardBorderWidth,
                    ),
                  ),
                  boxShadow: selected
                      ? [
                          AppShadows.selectedRing(
                            CarouselConfig.selectedRingWidth,
                          ),
                        ]
                      : AppShadows.soft,
                ),
                child: BrandLogoWidget(
                  brandName: brandName,
                  size: CarouselConfig.brandLogoSize,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: CarouselConfig.brandLabelWidth,
              child: Text(
                brandName,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: selected
                    ? AppTextStyles.brandLabel.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      )
                    : AppTextStyles.brandLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
