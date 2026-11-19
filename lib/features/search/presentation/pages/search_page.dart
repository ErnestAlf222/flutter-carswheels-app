import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';
import 'package:cars_wheels_app/features/search/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/widgets.dart';

/// Abre el detalle de un resultado; lo implementa la capa app.
typedef SearchResultOpener = void Function(
  BuildContext context,
  SearchResultEntity result,
);

/// Arma el sliver con la cuadrícula de tarjetas de modelo; lo implementa la capa app.
///
/// [resetKey] cambia cuando los resultados son de otra búsqueda (mercado, año,
/// marca o texto): la capa app reinicia entonces sus resúmenes y fotos.
typedef SearchResultsGridBuilder = Widget Function(
  BuildContext context,
  List<SearchResultEntity> results,
  String resetKey,
  ValueChanged<SearchResultEntity> onOpen,
);

/// Pantalla de búsqueda: encabezado con campo, alcance de marca y resultados.
class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.onOpenResult,
    required this.resultsGridBuilder,
    required this.selectorBuilder,
  });

  final SearchResultOpener onOpenResult;
  final SearchResultsGridBuilder resultsGridBuilder;

  /// Selector de mercado y año del encabezado; lo implementa la capa app.
  final WidgetBuilder selectorBuilder;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Los únicos estados son el controlador del campo y su foco (recursos del framework).
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SearchCubit>();
    _controller = TextEditingController(text: cubit.state.query);
    cubit.ensureIndex();
    // El foco se pide cuando la pantalla ya está construida.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusIfRequested());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _focusIfRequested() {
    if (!mounted) return;
    if (context.read<SearchCubit>().takeFocusRequest()) {
      _focusNode.requestFocus();
    }
  }

  // Mantiene el campo igual a la consulta cuando cambia sin teclear (recientes).
  void _syncField(BuildContext context, SearchState state) {
    if (_controller.text == state.query) return;
    _controller.value = TextEditingValue(
      text: state.query,
      selection: TextSelection.collapsed(offset: state.query.length),
    );
  }

  void _openResult(BuildContext context, SearchResultEntity result) {
    context.read<SearchCubit>().registerResultTap();
    widget.onOpenResult(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    return MultiBlocListener(
      listeners: [
        BlocListener<SearchCubit, SearchState>(
          listenWhen: (previous, current) => previous.query != current.query,
          listener: _syncField,
        ),
        BlocListener<SearchCubit, SearchState>(
          listenWhen: (previous, current) =>
              previous.focusRequestId != current.focusRequestId,
          listener: (_, _) => _focusIfRequested(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            final bottomPadding =
                NavConfig.footprint +
                MediaQuery.paddingOf(context).bottom +
                ModelGridConfig.listBottomGap;
            final scopeBrand = state.scopeBrand;
            final scope = state.scope;
            return RememberedScroll(
              store: context.read<ScrollOffsetStore>(),
              sectionKey: ScrollConfig.searchSectionKey,
              contextKey: scope?.key ?? '',
              builder: (context, scrollController) => Stack(
                children: [
                  CustomScrollView(
                    controller: scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: SearchHeaderDelegate(
                          topInset: MediaQuery.paddingOf(context).top,
                          selectorBuilder: widget.selectorBuilder,
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: cubit.onQueryChanged,
                          onSubmitted: (_) => cubit.submit(),
                          onClear: cubit.clearQuery,
                        ),
                      ),
                      if (scopeBrand != null)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: SearchScopeRowDelegate(
                            brand: scopeBrand,
                            onClear: cubit.clearScopeBrand,
                          ),
                        ),
                      if (state.isPreparing)
                        SliverToBoxAdapter(
                          child: SearchProgressWidget(
                            progress: state.indexStatus?.progress,
                          ),
                        ),
                      if (state.isPartial)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UiConfig.pageHorizontalPadding,
                            ),
                            child: SearchPartialNoticeWidget(
                              onRetry: cubit.retryIndex,
                            ),
                          ),
                        ),
                      ..._bodySlivers(context, state, bottomPadding),
                    ],
                  ),
                  ScrollToTopButton(controller: scrollController),
                  SearchFilterButton(
                    activeCount: state.filters.activeCount,
                    visible: state.totalResults > 0 || state.filters.isActive,
                    onTap: () => showSearchFiltersSheet(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Cuerpo según el estado: error, inicio, resultados o sin resultados.
  List<Widget> _bodySlivers(
    BuildContext context,
    SearchState state,
    double bottomPadding,
  ) {
    final cubit = context.read<SearchCubit>();
    if (state.hasBlockingError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorStateWidget(onRetry: cubit.retryIndex),
        ),
      ];
    }
    // Sin resultados previos y sin certeza (índice en obra o texto cambiando):
    // loader solo en esta zona, nunca el vacío.
    if ((state.isPreparing || state.isSearching) &&
        state.totalResults == 0 &&
        state.hasQuery) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: const AppLoader(compact: true),
          ),
        ),
      ];
    }
    if (!state.hasQuery) return _idleSlivers(context, state, bottomPadding);
    final scope = state.scope;
    final brand = state.scopeBrand;
    final slivers = <Widget>[];
    if (state.brandMatches.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: SearchBrandRowWidget(
            title: AppTexts.searchBrandMatchesTitle,
            brands: state.brandMatches,
            onSelect: cubit.selectBrand,
          ),
        ),
      );
    }
    if (state.totalResults > 0) {
      // Los filtros se aplican a las secciones de resultados, no a otros años.
      final service = cubit.filterService;
      final shown = service.apply(state.results, state.filters, state.traits);
      final shownOthers = service.apply(
        state.otherResults,
        state.filters,
        state.traits,
      );
      final pending = state.filters.engines.isEmpty
          ? 0
          : service.unanalyzedCount(
              [...state.results, ...state.otherResults],
              state.filters,
              state.traits,
            );
      final status = SearchAnalysisStatusWidget(
        isAnalyzing: state.isAnalyzing,
        analyzed: state.analyzedCount,
        total: state.analysisCandidates.length,
        pending: pending,
      );
      // El avance solo se muestra si los filtros dependen de lo analizado.
      final showStatus =
          state.filters.needsTraits && (state.isAnalyzing || pending > 0);
      // Con texto y alcance: "En {marca}" y "En otras marcas"; sin alcance, el conteo.
      final note = state.isTruncated
          ? AppTexts.searchResultsTruncatedLabel(state.totalResults)
          : null;
      if (state.filters.isActive && shown.isEmpty && shownOthers.isEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: SearchFilteredEmptyWidget(
              onClear: cubit.clearFilters,
              status: showStatus ? status : null,
            ),
          ),
        );
      } else if (brand != null && state.hasText) {
        if (showStatus) {
          slivers.add(_padded(child: status, top: 0, bottom: 0));
        }
        if (shown.isNotEmpty) {
          slivers.addAll(
            _section(
              context,
              state,
              header: SearchSectionHeaderWidget(
                title: AppTexts.searchInBrandTitle(brand),
                note: state.otherResults.isEmpty ? note : null,
              ),
              results: shown,
              resetKey: state.resultsKey,
            ),
          );
        } else if (state.results.isEmpty) {
          slivers.add(
            _padded(
              child: SearchScopeNoticeWidget(brand: brand),
              top: AppSpacing.xs,
              bottom: AppSpacing.xs,
            ),
          );
        }
        if (shownOthers.isNotEmpty) {
          slivers.addAll(
            _section(
              context,
              state,
              header: SearchSectionHeaderWidget(
                title: AppTexts.searchOtherBrandsTitle,
                note: note,
              ),
              results: shownOthers,
              resetKey: '${state.resultsKey} others',
            ),
          );
        }
      } else {
        if (showStatus) {
          slivers.add(_padded(child: status, top: 0, bottom: 0));
        }
        slivers.addAll(
          _section(
            context,
            state,
            header: SearchSectionHeaderWidget(
              title: AppTexts.searchResultsCountLabel(shown.length),
              subtitle: brand,
              note: note,
            ),
            results: shown,
            resetKey: state.resultsKey,
          ),
        );
      }
    } else if (state.hasNoResults && scope != null) {
      slivers.add(
        SliverToBoxAdapter(
          child: SearchNoResultsWidget(
            query: state.query,
            marketCode: scope.marketCode,
            year: scope.year,
            brand: brand,
            suggestions: state.suggestions,
            onSuggestion: cubit.applySuggestion,
            onSearchOtherYears: state.canSearchOtherYears
                ? cubit.searchInOtherYears
                : null,
          ),
        ),
      );
    }
    slivers.addAll(_otherYearsSlivers(context, state));
    slivers.add(SliverToBoxAdapter(child: SizedBox(height: bottomPadding)));
    return slivers;
  }

  // Encabezado de sección y su cuadrícula de tarjetas.
  List<Widget> _section(
    BuildContext context,
    SearchState state, {
    required Widget header,
    required List<SearchResultEntity> results,
    required String resetKey,
  }) {
    return [
      _padded(child: header, top: AppSpacing.xs, bottom: AppSpacing.s),
      SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiConfig.pageHorizontalPadding,
        ),
        sliver: widget.resultsGridBuilder(
          context,
          results,
          resetKey,
          (result) => _openResult(context, result),
        ),
      ),
    ];
  }

  // Búsqueda en otros años: enlace al final de la lista o sección con avance y filas.
  List<Widget> _otherYearsSlivers(BuildContext context, SearchState state) {
    final cubit = context.read<SearchCubit>();
    final status = state.otherYears;
    if (status != null) {
      return [
        _padded(
          child: SearchOtherYearsWidget(
            status: status,
            onCancel: cubit.cancelOtherYears,
            onOpen: (result) => _openResult(context, result),
          ),
          top: AppSpacing.m,
          bottom: 0,
        ),
      ];
    }
    final offerLink = state.totalResults > 0 && state.canSearchOtherYears;
    if (!offerLink) return const [];
    return [
      _padded(
        child: SearchOtherYearsButtonWidget(
          onTap: cubit.searchInOtherYears,
          failed: state.otherYearsFailed,
        ),
        top: AppSpacing.m,
        bottom: 0,
      ),
    ];
  }

  Widget _padded({
    required Widget child,
    required double top,
    required double bottom,
  }) => SliverPadding(
    padding: EdgeInsets.fromLTRB(
      UiConfig.pageHorizontalPadding,
      top,
      UiConfig.pageHorizontalPadding,
      bottom,
    ),
    sliver: SliverToBoxAdapter(child: child),
  );

  // Sin consulta ni alcance: explorar por marca y recientes, o un texto amable.
  List<Widget> _idleSlivers(
    BuildContext context,
    SearchState state,
    double bottomPadding,
  ) {
    final cubit = context.read<SearchCubit>();
    if (state.recents.isEmpty && state.brands.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: const SearchIdleHintWidget(),
          ),
        ),
      ];
    }
    return [
      if (state.brands.isNotEmpty)
        SliverToBoxAdapter(
          child: SearchBrandRowWidget(
            title: AppTexts.searchExploreByBrandTitle,
            brands: state.brands,
            onSelect: cubit.selectBrand,
          ),
        ),
      if (state.recents.isNotEmpty)
        SliverToBoxAdapter(
          child: SearchRecentsWidget(
            recents: state.recents,
            onSelect: cubit.useRecent,
            onRemove: (recent) => cubit.removeRecentSearch(recent.key),
            onClearAll: cubit.clearRecentSearches,
          ),
        ),
    ];
  }
}
