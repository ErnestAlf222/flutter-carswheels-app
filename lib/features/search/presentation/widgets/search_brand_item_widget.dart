import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';

/// Círculo blanco con el logo de una marca y su etiqueta debajo (hasta 2 líneas).
class SearchBrandItemWidget extends StatelessWidget {
  const SearchBrandItemWidget({
    super.key,
    required this.brandName,
    required this.onTap,
  });

  final String brandName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppTexts.searchBrandChipSemanticLabel(brandName),
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: SearchConfig.brandItemWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: SearchConfig.brandCircleSize,
                height: SearchConfig.brandCircleSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.soft,
                ),
                child: BrandLogoWidget(
                  brandName: brandName,
                  size: SearchConfig.brandLogoSize,
                ),
              ),
              const SizedBox(height: SearchConfig.brandItemGap),
              SizedBox(
                height: SearchConfig.brandLabelHeight,
                child: Text(
                  brandName,
                  maxLines: SearchConfig.brandLabelMaxLines,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
