import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Línea "¿Quisiste decir Ferrari?" con el nombre en negrita; tocarla busca eso.
///
/// Es texto, no etiqueta: sin fondo ni borde, con una flecha fina y un área
/// táctil de 44 px. Aparece con un fundido suave (sin él con animaciones
/// desactivadas).
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
    final still = MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: still ? 1.0 : 0.0, end: 1.0),
      duration: still
          ? Duration.zero
          : const Duration(
              milliseconds: SearchConfig.didYouMeanEnterMilliseconds,
            ),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: Column(
        children: [
          for (final suggestion in suggestions)
            _SuggestionLine(
              suggestion: suggestion,
              onTap: () => onSelect(suggestion),
            ),
        ],
      ),
    );
  }
}

class _SuggestionLine extends StatelessWidget {
  const _SuggestionLine({required this.suggestion, required this.onTap});

  final String suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppTexts.searchSuggestionSemanticLabel(suggestion),
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('search-suggestion-$suggestion'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.classChip),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: SearchConfig.didYouMeanTouchHeight,
          ),
          child: Center(
            widthFactor: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text.rich(
                TextSpan(
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.mutedText,
                  ),
                  children: [
                    const TextSpan(text: AppTexts.searchDidYouMeanLead),
                    TextSpan(
                      text: suggestion,
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: AppTexts.searchDidYouMeanTail),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(left: AppSpacing.xs / 2),
                        child: Icon(
                          Symbols.arrow_forward,
                          size: SearchConfig.didYouMeanIconSize,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
