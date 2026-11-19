import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_suggestions_widget.dart';

/// Sin resultados: texto buscado, mercado y año, sugerencias y buscar en otros años.
class SearchNoResultsWidget extends StatelessWidget {
  const SearchNoResultsWidget({
    super.key,
    required this.query,
    required this.marketCode,
    required this.year,
    this.brand,
    this.suggestions = const [],
    this.onSuggestion,
    this.onSearchOtherYears,
  });

  final String query;
  final String marketCode;
  final int year;

  /// Marca de alcance; sin texto, el aviso dice que no tiene modelos.
  final String? brand;
  final List<String> suggestions;
  final ValueChanged<String>? onSuggestion;

  /// Acción principal de la pantalla; nula si no hay otros años o ya se pidió.
  final VoidCallback? onSearchOtherYears;

  @override
  Widget build(BuildContext context) {
    final market = AppTexts.marketLabelOf(marketCode);
    final text = query.trim();
    final current = brand;
    final onSelect = onSuggestion;
    final onOtherYears = onSearchOtherYears;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConfig.pageHorizontalPadding,
        SearchConfig.emptyTopGap,
        UiConfig.pageHorizontalPadding,
        0,
      ),
      child: Column(
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
          if (suggestions.isNotEmpty && onSelect != null) ...[
            const SizedBox(height: AppSpacing.m),
            SearchSuggestionsWidget(
              suggestions: suggestions,
              onSelect: onSelect,
            ),
          ],
          if (onOtherYears != null) ...[
            const SizedBox(height: AppSpacing.m),
            AccentButton(
              label: AppTexts.searchOtherYearsAction,
              onPressed: onOtherYears,
            ),
          ],
        ],
      ),
    );
  }
}
