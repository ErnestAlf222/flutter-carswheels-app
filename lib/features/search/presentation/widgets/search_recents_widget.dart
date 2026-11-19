import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';

/// Búsquedas recientes: toque para repetir, "x" para borrar una y "Borrar todo".
class SearchRecentsWidget extends StatelessWidget {
  const SearchRecentsWidget({
    super.key,
    required this.recents,
    required this.onSelect,
    required this.onRemove,
    required this.onClearAll,
  });

  final List<RecentSearchEntity> recents;
  final ValueChanged<RecentSearchEntity> onSelect;
  final ValueChanged<RecentSearchEntity> onRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppTexts.searchRecentsTitle,
                style: AppTextStyles.sectionTitle,
              ),
            ),
            TextButton(
              onPressed: onClearAll,
              style: TextButton.styleFrom(foregroundColor: AppColors.ink),
              child: Text(
                AppTexts.searchClearAllLabel,
                style: AppTextStyles.caption.copyWith(color: AppColors.ink),
              ),
            ),
          ],
        ),
        for (final recent in recents)
          _RecentRow(
            key: ValueKey(recent.key),
            recent: recent,
            onSelect: () => onSelect(recent),
            onRemove: () => onRemove(recent),
          ),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({
    super.key,
    required this.recent,
    required this.onSelect,
    required this.onRemove,
  });

  final RecentSearchEntity recent;
  final VoidCallback onSelect;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SearchConfig.recentRowHeight,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: AppTexts.searchRecentSemanticLabel(recent.text),
              excludeSemantics: true,
              child: InkWell(
                onTap: onSelect,
                child: Row(
                  children: [
                    const Icon(
                      Symbols.history,
                      size: SearchConfig.fieldIconSize,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        recent.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: AppTexts.searchRecentRemoveSemanticLabel(recent.text),
            icon: const Icon(
              Symbols.close,
              size: SearchConfig.fieldIconSize,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
