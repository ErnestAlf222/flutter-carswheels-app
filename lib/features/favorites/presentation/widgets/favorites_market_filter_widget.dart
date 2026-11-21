import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/presentation/widgets/favorites_segment_widget.dart';

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
              FavoritesSegmentWidget(
                label: AppTexts.favoritesFilterAll,
                isSelected: selected == null,
                onTap: () => onSelected(null),
              ),
              for (final code in marketCodes) ...[
                const SizedBox(width: FavoritesConfig.filterGap),
                FavoritesSegmentWidget(
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
