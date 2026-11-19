import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';

/// Búsquedas recientes como filas planas con "Borrar todo".
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

/// Fila plana de una reciente: reloj, texto, "x" para borrarla y línea inferior.
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
    return Container(
      height: SearchConfig.recentRowHeight,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: UiConfig.pageHorizontalPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: AppTexts.searchRecentSemanticLabel(recent.text),
              excludeSemantics: true,
              child: InkWell(
                onTap: onSelect,
                child: SizedBox.expand(
                  child: Row(
                    children: [
                      const Icon(
                        Symbols.history,
                        size: SearchConfig.recentIconSize,
                        color: AppColors.mutedText,
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
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
                height: SearchConfig.recentRowHeight,
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
