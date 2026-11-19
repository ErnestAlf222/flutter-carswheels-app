import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';

/// Fila fija bajo el campo: "Buscando en [logo] Marca ✕"; el ✕ quita el alcance.
class SearchScopeRowDelegate extends SliverPersistentHeaderDelegate {
  const SearchScopeRowDelegate({required this.brand, required this.onClear});

  final String brand;
  final VoidCallback onClear;

  @override
  double get maxExtent => SearchConfig.scopeRowHeight;

  @override
  double get minExtent => SearchConfig.scopeRowHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: AppColors.background,
      child: SizedBox(
        height: SearchConfig.scopeRowHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UiConfig.pageHorizontalPadding,
          ),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  label: AppTexts.searchScopeSemanticLabel(brand),
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      Text(
                        AppTexts.searchScopePrefix,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        width: SearchConfig.scopeLogoCircleSize,
                        height: SearchConfig.scopeLogoCircleSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: BrandLogoWidget(
                          brandName: brand,
                          size: SearchConfig.scopeLogoSize,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyStrong,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: AppTexts.searchScopeClearSemanticLabel(brand),
                excludeSemantics: true,
                child: InkResponse(
                  key: const ValueKey('search-scope-clear'),
                  onTap: onClear,
                  radius: SearchConfig.scopeCloseSize / 2,
                  child: const SizedBox(
                    width: SearchConfig.scopeCloseSize,
                    height: SearchConfig.scopeCloseSize,
                    child: Icon(
                      Symbols.close,
                      size: SearchConfig.scopeCloseIconSize,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SearchScopeRowDelegate oldDelegate) =>
      brand != oldDelegate.brand;
}
