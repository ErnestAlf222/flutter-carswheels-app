import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_other_year_row_widget.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_section_header_widget.dart';

/// Botón secundario al final de una lista: "¿No es el que buscas?" y "Buscar en otros años".
class SearchOtherYearsButtonWidget extends StatelessWidget {
  const SearchOtherYearsButtonWidget({
    super.key,
    required this.onTap,
    this.failed = false,
  });

  final VoidCallback onTap;

  /// La búsqueda anterior falló: se avisa y el botón sirve de reintento.
  final bool failed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          failed
              ? AppTexts.searchOtherYearsFailed
              : AppTexts.searchOtherYearsPrompt,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.xs),
        OutlinedButton.icon(
          key: const ValueKey('search-other-years-button'),
          onPressed: onTap,
          icon: const Icon(
            Symbols.history,
            size: SearchConfig.otherYearsButtonIconSize,
          ),
          label: Text(
            AppTexts.searchOtherYearsAction,
            style: AppTextStyles.bodyStrong,
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            minimumSize: const Size(0, SearchConfig.otherYearsButtonHeight),
            side: const BorderSide(
              color: AppColors.ink,
              width: SearchConfig.otherYearsButtonBorderWidth,
            ),
            shape: const StadiumBorder(),
            iconAlignment: IconAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          ),
        ),
      ],
    );
  }
}

/// Sección "También en otros años": avance cancelable y filas halladas.
class SearchOtherYearsWidget extends StatelessWidget {
  const SearchOtherYearsWidget({
    super.key,
    required this.status,
    required this.onCancel,
    required this.onOpen,
    this.shown,
    this.filtersActive = false,
    this.analysis,
    this.onClearFilters,
  });

  final SearchOtherYearsStatusEntity status;
  final VoidCallback onCancel;
  final ValueChanged<SearchResultEntity> onOpen;

  /// Resultados ya filtrados; nulo muestra todos los de [status].
  final List<SearchResultEntity>? shown;

  /// Hay filtros activos: un año sin coincidencias se oculta.
  final bool filtersActive;

  /// Estado compacto del análisis de rasgos, si aplica.
  final Widget? analysis;

  /// Quita todos los filtros desde el aviso "Sin coincidencias".
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final results = shown ?? status.results;
    final noMatches =
        filtersActive && status.results.isNotEmpty && results.isEmpty;
    final analysisStatus = analysis;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SearchSectionHeaderWidget(title: AppTexts.searchOtherYearsTitle),
        const SizedBox(height: SearchConfig.sectionTitleGap),
        if (status.isBuilding) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
            child: AppLoader(
              key: ValueKey('search-other-years-loader'),
              compact: true,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppTexts.searchOtherYearsProgressLabel(status.checkedYears),
                  style: AppTextStyles.caption,
                ),
              ),
              TextButton(
                key: const ValueKey('search-other-years-cancel'),
                onPressed: onCancel,
                style: TextButton.styleFrom(foregroundColor: AppColors.ink),
                child: Text(
                  AppTexts.searchOtherYearsCancel,
                  style: AppTextStyles.bodyStrong,
                ),
              ),
            ],
          ),
        ] else if (noMatches)
          _NoMatches(onClear: onClearFilters)
        else if (results.isEmpty)
          Text(
            status.failedYears.isEmpty
                ? AppTexts.searchOtherYearsNone
                : AppTexts.searchOtherYearsFailed,
            style: AppTextStyles.caption,
          ),
        ?analysisStatus,
        for (final group in _groups(results, status.checkedYears))
          _YearGroup(group: group, onOpen: onOpen),
      ],
    );
  }

  // Agrupa por año: primero el más cercano al activo (orden de los años pedidos).
  static List<_YearGroupData> _groups(
    List<SearchResultEntity> results,
    List<int> yearOrder,
  ) {
    final byYear = <int, List<SearchResultEntity>>{};
    for (final result in results) {
      byYear.putIfAbsent(result.year, () => []).add(result);
    }
    final years = byYear.keys.toList()
      ..sort((a, b) {
        final ia = yearOrder.indexOf(a);
        final ib = yearOrder.indexOf(b);
        return (ia < 0 ? yearOrder.length : ia).compareTo(
          ib < 0 ? yearOrder.length : ib,
        );
      });
    return [for (final y in years) _YearGroupData(y, byYear[y]!)];
  }
}

class _YearGroupData {
  const _YearGroupData(this.year, this.results);

  final int year;
  final List<SearchResultEntity> results;
}

/// Aviso cuando los filtros no dejan ninguna coincidencia en otros años.
class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.onClear});

  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final clear = onClear;
    return Row(
      children: [
        Expanded(
          child: Text(
            AppTexts.searchOtherYearsNoFilterMatches,
            key: const ValueKey('search-other-years-no-filter-matches'),
            style: AppTextStyles.caption,
          ),
        ),
        if (clear != null)
          TextButton(
            key: const ValueKey('search-other-years-clear-filters'),
            onPressed: clear,
            style: TextButton.styleFrom(foregroundColor: AppColors.ink),
            child: Text(
              AppTexts.searchActiveFiltersClear,
              style: AppTextStyles.bodyStrong,
            ),
          ),
      ],
    );
  }
}

/// Un año: encabezado con línea y cantidad, y sus filas.
class _YearGroup extends StatelessWidget {
  const _YearGroup({required this.group, required this.onOpen});

  final _YearGroupData group;
  final ValueChanged<SearchResultEntity> onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SearchConfig.otherYearGroupGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Row(
              key: ValueKey('search-other-year-header-${group.year}'),
              children: [
                Text(group.year.toString(), style: AppTextStyles.cardTitle),
                const SizedBox(width: SearchConfig.otherYearGroupLineGap),
                const Expanded(
                  child: Divider(
                    height: SearchConfig.otherYearGroupLineThickness,
                    thickness: SearchConfig.otherYearGroupLineThickness,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(width: SearchConfig.otherYearGroupLineGap),
                Text(
                  AppTexts.searchResultsCountLabel(group.results.length),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          for (final result in group.results)
            Padding(
              padding: const EdgeInsets.only(top: SearchConfig.otherYearRowGap),
              child: SearchOtherYearRowWidget(
                key: ValueKey(
                  'search-other-year-${result.year}-${result.brand}-${result.groupName}',
                ),
                result: result,
                onTap: () => onOpen(result),
              ),
            ),
        ],
      ),
    );
  }
}
