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
                      SliverToBoxAdapter(
                        child: SearchHeaderWidget(
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
      // Con texto y alcance: "En {marca}" y "En otras marcas"; sin alcance, el conteo.
      final note = state.isTruncated
          ? AppTexts.searchResultsTruncatedLabel(state.totalResults)
          : null;
      if (brand != null && state.hasText) {
        if (state.results.isNotEmpty) {
          slivers.addAll(
            _section(
              context,
              state,
              header: SearchSectionHeaderWidget(
                title: AppTexts.searchInBrandTitle(brand),
                note: state.otherResults.isEmpty ? note : null,
              ),
              results: state.results,
              resetKey: state.resultsKey,
            ),
          );
        } else {
          slivers.add(
            _padded(
              child: SearchScopeNoticeWidget(brand: brand),
              top: AppSpacing.xs,
              bottom: AppSpacing.xs,
            ),
          );
        }
        if (state.otherResults.isNotEmpty) {
          slivers.addAll(
            _section(
              context,
              state,
              header: SearchSectionHeaderWidget(
                title: AppTexts.searchOtherBrandsTitle,
                note: note,
              ),
              results: state.otherResults,
              resetKey: '${state.resultsKey} others',
            ),
          );
        }
      } else {
        slivers.addAll(
          _section(
            context,
            state,
            header: SearchSectionHeaderWidget(
              title: AppTexts.searchResultsCountLabel(state.results.length),
              subtitle: brand,
              note: note,
            ),
            results: state.results,
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
