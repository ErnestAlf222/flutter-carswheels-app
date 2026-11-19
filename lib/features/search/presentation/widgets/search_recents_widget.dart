import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';

/// Búsquedas recientes en una sola fila horizontal de chips y "Borrar todo".
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
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UiConfig.pageHorizontalPadding,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppTexts.searchRecentsTitle,
                  style: AppTextStyles.cardTitle,
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
        ),
        SizedBox(
          height: SearchConfig.recentChipHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: UiConfig.pageHorizontalPadding,
            ),
            itemCount: recents.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: SearchConfig.recentChipGap),
            itemBuilder: (context, index) {
              final recent = recents[index];
              return _RecentChip(
                key: ValueKey(recent.key),
                recent: recent,
                onSelect: () => onSelect(recent),
                onRemove: () => onRemove(recent),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Chip de una reciente: reloj, texto y una "x" pequeña para borrarla.
class _RecentChip extends StatelessWidget {
  const _RecentChip({
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
    final radius = BorderRadius.circular(AppRadii.pill);
    return Container(
      constraints: const BoxConstraints(
        maxWidth: SearchConfig.recentChipMaxWidth,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Semantics(
              button: true,
              label: AppTexts.searchRecentSemanticLabel(recent.text),
              excludeSemantics: true,
              child: InkWell(
                onTap: onSelect,
                borderRadius: radius,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: SearchConfig.chipHorizontalPadding,
                    right: AppSpacing.xs / 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Symbols.history,
                        size: SearchConfig.recentIconSize,
                        color: AppColors.mutedText,
                      ),
                      const SizedBox(width: AppSpacing.xs / 2),
                      Flexible(
                        child: Text(
                          recent.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyStrong,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: AppTexts.searchRecentRemoveSemanticLabel(recent.text),
            excludeSemantics: true,
            child: InkResponse(
              key: ValueKey('search-recent-remove-${recent.key}'),
              onTap: onRemove,
              radius: SearchConfig.recentRemoveSize / 2,
              child: const SizedBox(
                width: SearchConfig.recentRemoveSize,
                height: SearchConfig.recentChipHeight,
                child: Icon(
                  Symbols.close,
                  size: SearchConfig.recentRemoveIconSize,
                  color: AppColors.mutedText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
