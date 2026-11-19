import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Píldora translúcida sobre el encabezado oscuro con el mercado y el año.
class SearchContextChipWidget extends StatelessWidget {
  const SearchContextChipWidget({
    super.key,
    required this.marketCode,
    required this.year,
  });

  final String marketCode;
  final int year;

  @override
  Widget build(BuildContext context) {
    final market = AppTexts.marketLabelOf(marketCode);
    return Semantics(
      label: AppTexts.searchContextSemanticLabel(market, year),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SearchConfig.chipHorizontalPadding,
          vertical: SearchConfig.chipVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.onDarkPill,
          borderRadius: BorderRadius.circular(AppRadii.classChip),
        ),
        child: Text(
          AppTexts.searchContextChipLabel(market, year),
          style: AppTextStyles.onDarkCaption,
        ),
      ),
    );
  }
}
