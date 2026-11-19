import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';

/// Círculo blanco con el logo de una marca (o "Todas") y su etiqueta debajo.
class SearchBrandItemWidget extends StatelessWidget {
  const SearchBrandItemWidget({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
    this.brandName,
  });

  final String label;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  /// Marca cuyo logo se muestra; nulo en el elemento "Todas".
  final String? brandName;

  @override
  Widget build(BuildContext context) {
    final brand = brandName;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
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
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: selected
                      ? Border.all(
                          color: AppColors.ink,
                          width: SearchConfig.brandRingWidth,
                        )
                      : null,
                  boxShadow: selected ? null : AppShadows.soft,
                ),
                child: brand == null
                    ? const Icon(
                        Symbols.apps,
                        size: SearchConfig.fieldIconSize,
                        color: AppColors.ink,
                      )
                    : BrandLogoWidget(
                        brandName: brand,
                        size: SearchConfig.brandLogoSize,
                      ),
              ),
              const SizedBox(height: SearchConfig.brandItemGap),
              SizedBox(
                height: SearchConfig.brandLabelHeight,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: selected
                      ? AppTextStyles.caption.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        )
                      : AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
