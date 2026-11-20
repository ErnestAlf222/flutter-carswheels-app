import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Filtro de texto segmentado "Todos · EE. UU. · México", sin chips con relleno.
///
/// [selected] es el código de mercado elegido; nulo es "Todos".
class FavoritesMarketFilterWidget extends StatelessWidget {
  const FavoritesMarketFilterWidget({
    super.key,
    required this.marketCodes,
    required this.selected,
    required this.onSelected,
  });

  /// Mercados presentes en los favoritos, en el orden en que se muestran.
  final List<String> marketCodes;
  final String? selected;
  final ValueChanged<String?> onSelected;

  static String _labelOf(String code) => code == MarketConfig.mexicoCode
      ? AppTexts.marketMexicoLabel
      : AppTexts.marketUnitedStatesLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: AppTexts.favoritesFilterSemanticLabel,
      child: SizedBox(
        height: FavoritesConfig.filterHeight,
        // Con texto grande el filtro se encoge en vez de desbordar.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Segment(
                label: AppTexts.favoritesFilterAll,
                isSelected: selected == null,
                onTap: () => onSelected(null),
              ),
              for (final code in marketCodes) ...[
                const SizedBox(width: FavoritesConfig.filterGap),
                _Segment(
                  label: _labelOf(code),
                  isSelected: selected == code,
                  onTap: () => onSelected(code),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Un texto del filtro; el elegido va en tinta fuerte con una línea debajo.
class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        // El ancho del texto manda: la línea de abajo se estira a él.
        child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: isSelected
                    ? AppTextStyles.bodyStrong
                    : AppTextStyles.bodyStrong.copyWith(
                        color: AppColors.mutedText,
                      ),
              ),
              const SizedBox(height: FavoritesConfig.filterUnderlineGap),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: const SizedBox(
                  height: FavoritesConfig.filterUnderlineHeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
