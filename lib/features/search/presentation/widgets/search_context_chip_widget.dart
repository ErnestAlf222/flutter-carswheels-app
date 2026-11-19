import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Chip no editable con el mercado y el año en uso.
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
          color: AppColors.accentTint,
          borderRadius: BorderRadius.circular(AppRadii.classChip),
        ),
        child: Text(
          AppTexts.searchContextChipLabel(market, year),
          style: AppTextStyles.caption.copyWith(color: AppColors.mutedText),
        ),
      ),
    );
  }
}
