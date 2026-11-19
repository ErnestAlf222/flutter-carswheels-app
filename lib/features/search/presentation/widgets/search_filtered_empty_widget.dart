import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Con filtros activos no queda ningún resultado: aviso y "Limpiar filtros".
class SearchFilteredEmptyWidget extends StatelessWidget {
  const SearchFilteredEmptyWidget({
    super.key,
    required this.onClear,
    this.status,
  });

  final VoidCallback onClear;

  /// Avance del análisis, si aún hay resultados por analizar.
  final Widget? status;

  @override
  Widget build(BuildContext context) {
    final analysis = status;
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
            Symbols.filter_alt_off,
            size: SearchConfig.filterEmptyIconSize,
            color: AppColors.mutedText,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppTexts.searchFiltersEmptyTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyStrong,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppTexts.searchFiltersEmptyHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
          if (analysis != null) ...[
            const SizedBox(height: AppSpacing.s),
            analysis,
          ],
          const SizedBox(height: AppSpacing.m),
          AccentButton(
            key: const ValueKey('search-filters-clear-all'),
            label: AppTexts.searchFiltersClearAll,
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}
