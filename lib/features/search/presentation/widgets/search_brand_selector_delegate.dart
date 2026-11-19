import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_brand_item_widget.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_progress_widget.dart';

/// Fila fija de marcas: "Todas" primero y luego todas las del índice.
class SearchBrandSelectorDelegate extends SliverPersistentHeaderDelegate {
  const SearchBrandSelectorDelegate({
    required this.brands,
    required this.selectedBrand,
    required this.onSelectBrand,
    required this.onClear,
    required this.showProgress,
    this.progress,
  });

  final List<String> brands;
  final String? selectedBrand;
  final ValueChanged<String> onSelectBrand;
  final VoidCallback onClear;

  /// La barra amarilla del índice se muestra mientras se prepara.
  final bool showProgress;
  final double? progress;

  @override
  double get maxExtent => SearchConfig.brandRowHeight;

  @override
  double get minExtent => SearchConfig.brandRowHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        children: [
          ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: UiConfig.pageHorizontalPadding,
              vertical: SearchConfig.brandRowVerticalPadding,
            ),
            itemCount: brands.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) {
              if (index == 0) {
                return SearchBrandItemWidget(
                  key: const ValueKey('search-brand-all'),
                  label: AppTexts.searchAllBrandsLabel,
                  semanticLabel: AppTexts.searchAllBrandsSemanticLabel,
                  selected: selectedBrand == null,
                  onTap: onClear,
                );
              }
              final brand = brands[index - 1];
              return SearchBrandItemWidget(
                key: ValueKey('search-brand-$brand'),
                label: brand,
                semanticLabel: AppTexts.searchBrandChipSemanticLabel(brand),
                brandName: brand,
                selected: selectedBrand == brand,
                onTap: () => onSelectBrand(brand),
              );
            },
          ),
          if (showProgress)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: SearchProgressWidget(progress: progress),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(SearchBrandSelectorDelegate oldDelegate) =>
      brands != oldDelegate.brands ||
      selectedBrand != oldDelegate.selectedBrand ||
      showProgress != oldDelegate.showProgress ||
      progress != oldDelegate.progress;
}
