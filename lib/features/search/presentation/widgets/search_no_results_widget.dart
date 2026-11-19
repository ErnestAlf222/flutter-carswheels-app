import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Sin resultados: el texto buscado, el mercado y año, y quitar el filtro de marca.
class SearchNoResultsWidget extends StatelessWidget {
  const SearchNoResultsWidget({
    super.key,
    required this.query,
    required this.marketCode,
    required this.year,
    this.brand,
    this.onClearBrand,
  });

  final String query;
  final String marketCode;
  final int year;

  /// Marca filtrada; con ella aparece el botón para quitar el filtro.
  final String? brand;
  final VoidCallback? onClearBrand;

  @override
  Widget build(BuildContext context) {
    final market = AppTexts.marketLabelOf(marketCode);
    final text = query.trim();
    final current = brand;
    final onClear = onClearBrand;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiConfig.pageHorizontalPadding,
        ),
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
              text.isEmpty && current != null
                  ? AppTexts.searchNoResultsForBrandTitle(current)
                  : AppTexts.searchNoResultsTitle(text),
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
            if (current != null && onClear != null) ...[
              const SizedBox(height: AppSpacing.m),
              OutlinedButton(
                onPressed: onClear,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.ink),
                  minimumSize: const Size(0, UiConfig.compactButtonHeight),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  AppTexts.searchRemoveBrandFilterLabel,
                  style: AppTextStyles.bodyStrong,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
