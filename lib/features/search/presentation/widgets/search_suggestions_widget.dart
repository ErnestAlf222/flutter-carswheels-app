import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Chips "¿Quisiste decir «…»?"; tocar uno reemplaza el texto buscado.
class SearchSuggestionsWidget extends StatelessWidget {
  const SearchSuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.onSelect,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.pill);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: SearchConfig.suggestionChipGap,
      runSpacing: SearchConfig.suggestionChipGap,
      children: [
        for (final suggestion in suggestions)
          Semantics(
            button: true,
            label: AppTexts.searchSuggestionSemanticLabel(suggestion),
            excludeSemantics: true,
            child: Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: const BorderSide(color: AppColors.outline),
              ),
              child: InkWell(
                key: ValueKey('search-suggestion-$suggestion'),
                borderRadius: radius,
                onTap: () => onSelect(suggestion),
                child: Container(
                  height: SearchConfig.suggestionChipHeight,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  child: Text(
                    AppTexts.searchSuggestionLabel(suggestion),
                    style: AppTextStyles.bodyStrong,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
