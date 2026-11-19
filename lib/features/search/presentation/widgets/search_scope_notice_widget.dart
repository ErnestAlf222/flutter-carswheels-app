import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Nota "Sin resultados en {marca}" cuando solo hay coincidencias en otras marcas.
class SearchScopeNoticeWidget extends StatelessWidget {
  const SearchScopeNoticeWidget({super.key, required this.brand});

  final String brand;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Symbols.info,
          size: SearchConfig.recentIconSize,
          color: AppColors.mutedText,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            AppTexts.searchNoResultsInBrand(brand),
            style: AppTextStyles.bodyStrong,
          ),
        ),
      ],
    );
  }
}
