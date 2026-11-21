import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/domain/domain.dart';
import 'package:cars_wheels_app/features/favorites/presentation/widgets/favorites_segment_widget.dart';

/// Orden de Favoritos en texto segmentado "Recientes · A–Z · Más eficiente".
class FavoritesSortWidget extends StatelessWidget {
  const FavoritesSortWidget({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final FavoriteSortMode selected;
  final ValueChanged<FavoriteSortMode> onSelected;

  static String _labelOf(FavoriteSortMode mode) => switch (mode) {
    FavoriteSortMode.recent => FavoritesTexts.sortRecent,
    FavoriteSortMode.alphabetical => FavoritesTexts.sortAlphabetical,
    FavoriteSortMode.mostEfficient => FavoritesTexts.sortMostEfficient,
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: FavoritesTexts.sortSemanticLabel,
      child: SizedBox(
        height: FavoritesConfig.filterHeight,
        // Con texto grande el control se encoge en vez de desbordar.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, mode) in FavoriteSortMode.values.indexed) ...[
                if (index > 0) const SizedBox(width: FavoritesConfig.filterGap),
                FavoritesSegmentWidget(
                  label: _labelOf(mode),
                  isSelected: selected == mode,
                  onTap: () => onSelected(mode),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
