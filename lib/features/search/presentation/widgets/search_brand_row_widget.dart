import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_brand_item_widget.dart';

/// Título en overline y una fila horizontal de marcas con logo redondo.
class SearchBrandRowWidget extends StatelessWidget {
  const SearchBrandRowWidget({
    super.key,
    required this.title,
    required this.brands,
    required this.onSelect,
  });

  final String title;
  final List<String> brands;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            UiConfig.pageHorizontalPadding,
            AppSpacing.xs,
            UiConfig.pageHorizontalPadding,
            0,
          ),
          child: Text(title.toUpperCase(), style: AppTextStyles.label),
        ),
        SizedBox(
          height: SearchConfig.brandRowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: UiConfig.pageHorizontalPadding,
              vertical: SearchConfig.brandRowVerticalPadding,
            ),
            itemCount: brands.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) {
              final brand = brands[index];
              return SearchBrandItemWidget(
                key: ValueKey('search-brand-$brand'),
                brandName: brand,
                onTap: () => onSelect(brand),
              );
            },
          ),
        ),
      ],
    );
  }
}
