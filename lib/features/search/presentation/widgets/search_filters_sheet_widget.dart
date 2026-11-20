import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';
import 'package:cars_wheels_app/features/search/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_analysis_status_widget.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_filter_chip_widget.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_filter_labels.dart';

/// Abre la hoja de filtros; al abrir pide el análisis y al cerrar lo cancela.
Future<void> showSearchFiltersSheet(BuildContext context) {
  final cubit = context.read<SearchCubit>();
  // Sin foco en el campo: al cerrar la hoja no debe reaparecer el teclado.
  FocusManager.instance.primaryFocus?.unfocus();
  cubit.filtersSheetOpened();
  return showModalBottomSheet<void>(
    context: context,
    // Navegador raíz: la hoja queda por encima de la barra flotante de navegación.
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
    ),
    builder: (_) => BlocProvider<SearchCubit>.value(
      value: cubit,
      child: const SearchFiltersSheet(),
    ),
  ).whenComplete(cubit.filtersSheetClosed);
}

/// Hoja de filtros: motorización, marca y orden calculados sobre los resultados.
class SearchFiltersSheet extends StatelessWidget {
  const SearchFiltersSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final maxHeight =
        MediaQuery.sizeOf(context).height *
        SearchConfig.filterSheetMaxHeightFraction;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) => _Content(state: state),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    final service = cubit.filterService;
    final filters = state.filters;
    final all = [...state.results, ...state.otherResults];
    final visible =
        service.apply(state.results, filters, state.traits).length +
        service.apply(state.otherResults, filters, state.traits).length;
    final pending = filters.engines.isEmpty
        ? 0
        : service.unanalyzedCount(all, filters, state.traits);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Container(
              key: const ValueKey('search-filters-handle'),
              width: SearchConfig.filterSheetHandleWidth,
              height: SearchConfig.filterSheetHandleHeight,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UiConfig.pageHorizontalPadding,
              AppSpacing.m,
              UiConfig.pageHorizontalPadding,
              0,
            ),
            child: Text(
              AppTexts.searchFiltersTitle,
              style: AppTextStyles.cardTitle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UiConfig.pageHorizontalPadding,
              AppSpacing.xs,
              UiConfig.pageHorizontalPadding,
              0,
            ),
            child: Text(
              AppTexts.searchFiltersAlsoOtherYears,
              key: const ValueKey('search-filters-other-years-note'),
              style: AppTextStyles.caption,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiConfig.pageHorizontalPadding,
            ),
            child: SearchAnalysisStatusWidget(
              isAnalyzing: state.isAnalyzing,
              analyzed: state.analyzedCount,
              total: state.analysisCandidates.length,
              pending: pending,
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: UiConfig.pageHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._engineSection(cubit, state, all),
                  ..._brandSection(cubit, state, all),
                  ..._sortSection(cubit, state),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UiConfig.pageHorizontalPadding,
              SearchConfig.filterFooterGap,
              UiConfig.pageHorizontalPadding,
              AppSpacing.s,
            ),
            child: Row(
              children: [
                TextButton(
                  key: const ValueKey('search-filters-clear'),
                  onPressed: filters.isActive ? cubit.clearFilters : null,
                  child: Text(
                    AppTexts.searchFiltersClear,
                    style: AppTextStyles.bodyStrong,
                  ),
                ),
                const Spacer(),
                AccentButton(
                  key: const ValueKey('search-filters-apply'),
                  label: AppTexts.searchFiltersApplyLabel(visible),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Solo las motorizaciones que existen entre los resultados analizados.
  List<Widget> _engineSection(
    SearchCubit cubit,
    SearchState state,
    List<SearchResultEntity> all,
  ) {
    final service = cubit.filterService;
    final options = {
      ...service.availableEngines(all, state.traits),
      ...state.filters.engines,
    };
    if (options.isEmpty) return const [];
    final counts = service.engineCounts(all, state.filters, state.traits);
    return _section(AppTexts.searchFiltersEngineTitle, [
      for (final option in SearchEngineOption.values)
        if (options.contains(option))
          SearchFilterChip(
            key: ValueKey('search-filter-engine-${option.name}'),
            label: SearchFilterLabels.engine(option),
            count: counts[option],
            selected: state.filters.engines.contains(option),
            enabled:
                counts[option]! > 0 || state.filters.engines.contains(option),
            onTap: () => cubit.toggleEngine(option),
          ),
    ]);
  }

  // Solo si los resultados abarcan más de una marca.
  List<Widget> _brandSection(
    SearchCubit cubit,
    SearchState state,
    List<SearchResultEntity> all,
  ) {
    final brands = {for (final result in all) result.brand}.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    if (brands.length < 2) return const [];
    final counts = cubit.filterService.brandCounts(
      all,
      state.filters,
      state.traits,
    );
    return _section(AppTexts.searchFiltersBrandTitle, [
      for (final brand in brands)
        SearchFilterChip(
          key: ValueKey('search-filter-brand-$brand'),
          label: brand,
          count: counts[brand] ?? 0,
          selected: state.filters.brands.contains(brand),
          enabled:
              (counts[brand] ?? 0) > 0 || state.filters.brands.contains(brand),
          onTap: () => cubit.toggleBrandFilter(brand),
        ),
    ]);
  }

  List<Widget> _sortSection(SearchCubit cubit, SearchState state) {
    final sort = state.filters.sort;
    return [
      ..._section(AppTexts.searchFiltersSortTitle, [
        SearchFilterChip(
          key: const ValueKey('search-filter-sort-alphabetical'),
          label: AppTexts.searchFiltersSortAlphabetical,
          selected: sort == SearchSortOrder.alphabetical,
          onTap: () => cubit.setSortOrder(SearchSortOrder.alphabetical),
        ),
        SearchFilterChip(
          key: const ValueKey('search-filter-sort-efficient'),
          label: AppTexts.searchFiltersSortMostEfficient,
          selected: sort == SearchSortOrder.mostEfficient,
          onTap: () => cubit.setSortOrder(SearchSortOrder.mostEfficient),
        ),
      ]),
      Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Text(
          AppTexts.searchFiltersSortEfficiencyHelp,
          style: AppTextStyles.caption,
        ),
      ),
    ];
  }

  List<Widget> _section(String title, List<Widget> chips) => [
    const SizedBox(height: SearchConfig.filterSectionGap),
    Text(title.toUpperCase(), style: AppTextStyles.label),
    const SizedBox(height: AppSpacing.xs),
    Wrap(
      spacing: SearchConfig.filterChipGap,
      runSpacing: SearchConfig.filterChipGap,
      children: chips,
    ),
  ];
}
