import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Fila delgada bajo el encabezado de resultados: "Filtros activos (N)" abre la
/// hoja y "Limpiar" quita todos los filtros. Sin chips ni relleno.
class SearchActiveFiltersRow extends StatelessWidget {
  const SearchActiveFiltersRow({
    super.key,
    required this.count,
    required this.onOpen,
    required this.onClear,
  });

  final int count;
  final VoidCallback onOpen;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SizedBox(
        height: SearchConfig.activeFiltersRowHeight,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                key: const ValueKey('search-active-filters-open'),
                behavior: HitTestBehavior.opaque,
                onTap: onOpen,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppTexts.searchActiveFiltersLabel(count),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              key: const ValueKey('search-active-filters-clear'),
              onPressed: onClear,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.ink,
                minimumSize: const Size(0, SearchConfig.activeFiltersRowHeight),
                padding: const EdgeInsets.only(left: AppSpacing.s),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppTexts.searchActiveFiltersClear,
                style: AppTextStyles.bodyStrong,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
