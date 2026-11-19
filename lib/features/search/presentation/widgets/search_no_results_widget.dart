import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Sin resultados: el texto buscado, el mercado y año en uso y una sugerencia.
class SearchNoResultsWidget extends StatelessWidget {
  const SearchNoResultsWidget({
    super.key,
    required this.query,
    required this.marketCode,
    required this.year,
  });

  final String query;
  final String marketCode;
  final int year;

  @override
  Widget build(BuildContext context) {
    final market = AppTexts.marketLabelOf(marketCode);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Symbols.search_off,
            size: SearchConfig.emptyIconSize,
            color: AppColors.mutedText,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppTexts.searchNoResultsTitle(query.trim()),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyStrong,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppTexts.searchNoResultsScope(market, year),
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
          Text(
            AppTexts.searchNoResultsSuggestion,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
