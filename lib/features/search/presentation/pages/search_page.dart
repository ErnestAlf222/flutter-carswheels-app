import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/connectivity/connectivity.dart';
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

/// Arma la fila de sugerencias "para ti"; lo implementa la capa app.
///
/// [resetKey] cambia con el mercado, el año o la visita: la capa app reinicia
/// entonces sus fotos y resúmenes.
typedef SearchPicksBuilder = Widget Function(
  BuildContext context,
  List<SearchResultEntity> picks,
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
    this.title = AppTexts.searchPageTitle,
    this.onBack,
    this.reserveNavSpace = true,
    this.compact = false,
    this.belowHeader,
    this.picksBuilder,
    this.picksSeed,
    this.picksCount = SearchConfig.picksCount,
    this.picksFirst = false,
    this.bandStyle,
    this.infiniteFeed = false,
  });

  /// Con el campo vacío y sin filtros, sigue un feed de más autos que carga por
  /// páginas al llegar al final; el selector de Comparar no lo usa.
  final bool infiniteFeed;

  /// Identidad propia de la banda compacta (el selector de Comparar).
  final SearchBandStyle? bandStyle;

  /// Las sugerencias van antes que las marcas y los recientes.
  final bool picksFirst;

  /// Sugerencias con el campo vacío; sin él (selector) no se muestran.
  final SearchPicksBuilder? picksBuilder;

  /// Semilla de las sugerencias de esta visita; por defecto, una al azar.
  final int? picksSeed;

  /// Cuántas sugerencias se piden al índice (la capa app puede descartar algunas).
  final int picksCount;

  /// Título del encabezado; el modo selección usa el suyo.
  final String title;

  /// Con valor, el encabezado muestra volver (modo selección: sin menú flotante).
  final VoidCallback? onBack;

  /// Dentro de una hoja: sin encabezado grande ni selector de mercado y año.
  ///
  /// [onBack] hace de cierre de la hoja.
  final bool compact;

  /// Aviso opcional bajo el encabezado; la capa app lo arma (modo comparar).
  final Widget? belowHeader;

  /// Deja libre el espacio del menú flotante al final de la lista.
  final bool reserveNavSpace;

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

  // Cada visita (estado nuevo de la pantalla) trae sus propias sugerencias.
  late final int _picksSeed = widget.picksSeed ?? Random().nextInt(1 << 30);

  // Feed infinito: lo ya mostrado en esta visita, su alcance y la página en camino.
  List<SearchResultEntity> _feed = const [];
  String _feedScopeKey = '';
  bool _feedLoading = false;
  bool _feedDone = false;
  Timer? _feedTimer;
  ScrollController? _scrollController;

  // Vaciado con la "x": el texto y la lista se desvanecen y luego se vacía.
  bool _clearing = false;
  Timer? _clearTimer;

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
    _clearTimer?.cancel();
    _feedTimer?.cancel();
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

  // El texto y los resultados se desvanecen; luego se vacía y entran las sugerencias.
  void _clearField() {
    final cubit = context.read<SearchCubit>();
    if (MediaQuery.of(context).disableAnimations) {
      cubit.clearQuery();
      return;
    }
    if (_clearing) return;
    setState(() => _clearing = true);
    _clearTimer = Timer(AppMotion.fast, () {
      cubit.clearQuery();
      if (mounted) setState(() => _clearing = false);
    });
  }

  // El feed solo existe con el campo vacío y sin filtros, como las sugerencias.
  bool _feedActive(SearchState state) =>
      widget.infiniteFeed &&
      state.scope != null &&
      state.query.isEmpty &&
      !state.filters.isActive &&
      !state.hasQuery;

  // Identidades que el feed no debe repetir: las sugerencias y lo ya mostrado.
  Set<String> _shownKeys(List<SearchResultEntity> picks) => {
    for (final result in [...picks, ..._feed])
      '${result.brand}${SearchConfig.feedKeySeparator}${result.groupName ?? ''}',
  };

  // Otro mercado o año reinicia el feed; lo en camino de antes se descarta.
  void _syncFeedScope(SearchState state) {
    // Un índice que vuelve a crecer (reintento) reabre el feed.
    if (state.isPreparing) _feedDone = false;
    final key = state.scope?.key ?? '';
    if (key == _feedScopeKey) return;
    _feedScopeKey = key;
    _feed = const [];
    _feedLoading = false;
    _feedDone = false;
    _feedTimer?.cancel();
  }

  // Pide la siguiente página si hay algo que mostrar y se está cerca del final.
  void _requestMore({bool force = false}) {
    if (!mounted || _feedLoading || _feedDone) return;
    final cubit = context.read<SearchCubit>();
    final state = cubit.state;
    if (!_feedActive(state)) return;
    final controller = _scrollController;
    final position = (controller?.hasClients ?? false)
        ? controller!.position
        : null;
    final near =
        position == null ||
        position.extentAfter < SearchConfig.feedLoadThreshold;
    if (!near && !force) return;
    final picks = cubit.picksFor(_picksSeed, count: widget.picksCount);
    // El feed empieza cuando las sugerencias ya están.
    if (picks.isEmpty) return;
    final page = cubit.feedPage(_picksSeed, exclude: _shownKeys(picks));
    if (page.results.isEmpty) {
      // Sin nada que mostrar y con el índice completo, ya no se vuelve a calcular.
      _feedDone = !page.isBuilding;
      return;
    }
    final scopeKey = _feedScopeKey;
    setState(() => _feedLoading = true);
    final reduced = MediaQuery.of(context).disableAnimations;
    _feedTimer = Timer(
      reduced
          ? Duration.zero
          : const Duration(
              milliseconds: SearchConfig.feedPageDelayMilliseconds,
            ),
      () {
        if (!mounted || scopeKey != _feedScopeKey) return;
        // Se pide de nuevo: el índice pudo crecer mientras tanto.
        final latest = cubit.feedPage(
          _picksSeed,
          exclude: _shownKeys(
            cubit.picksFor(_picksSeed, count: widget.picksCount),
          ),
        );
        setState(() {
          _feed = [..._feed, ...latest.results];
          _feedLoading = false;
        });
        _scheduleFill();
      },
    );
  }

  // Tras cada cambio, si la lista aún no llena la pantalla pide otra página.
  void _scheduleFill() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestMore());
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
                (widget.reserveNavSpace ? NavConfig.footprint : 0.0) +
                MediaQuery.paddingOf(context).bottom +
                ModelGridConfig.listBottomGap;
            final scopeBrand = state.scopeBrand;
            final scope = state.scope;
            _syncFeedScope(state);
            if (_feedActive(state)) _scheduleFill();
            return RememberedScroll(
              store: context.read<ScrollOffsetStore>(),
              sectionKey: ScrollConfig.searchSectionKey,
              contextKey: scope?.key ?? '',
              builder: (context, scrollController) {
                _scrollController = scrollController;
                return Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        _scrollController = scrollController;
                        if (notification.depth == 0 &&
                            notification.metrics.extentAfter <
                                SearchConfig.feedLoadThreshold) {
                          _requestMore();
                        }
                        return false;
                      },
                      child: CustomScrollView(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        slivers: [
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: widget.compact
                                ? SearchCompactHeaderDelegate(
                                    title: widget.title,
                                    onClose: widget.onBack,
                                    style: widget.bandStyle,
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    onChanged: cubit.onQueryChanged,
                                    onSubmitted: (_) => cubit.submit(),
                                    onClear: _clearField,
                                    fadingText: _clearing,
                                  )
                                : SearchHeaderDelegate(
                                    title: widget.title,
                                    onBack: widget.onBack,
                                    topInset: MediaQuery.paddingOf(context).top,
                                    selectorBuilder: widget.selectorBuilder,
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    onChanged: cubit.onQueryChanged,
                                    onSubmitted: (_) => cubit.submit(),
                                    onClear: _clearField,
                                    fadingText: _clearing,
                                  ),
                          ),
                          const ConnectivityBandSliver(),
                          if (widget.belowHeader case final notice?)
                            SliverToBoxAdapter(child: notice),
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
                          if (state.indexStatus != null &&
                              (state.isPartial ||
                                  (state.isPreparing && state.hasQuery)))
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: UiConfig.pageHorizontalPadding,
                                ),
                                child: SearchPartialNoticeWidget(
                                  indexed: state.indexStatus!.indexedBrands,
                                  total: state.indexStatus!.totalBrands,
                                  onRetry: state.isPartial
                                      ? cubit.retryIndex
                                      : null,
                                ),
                              ),
                            ),
                          // Al vaciar con la "x" la lista se desvanece y vuelve ya con
                          // las sugerencias, sin pasar por "sin resultados".
                          for (final sliver in _bodySlivers(
                            context,
                            state,
                            bottomPadding,
                          ))
                            SliverAnimatedOpacity(
                              opacity: _clearing ? 0 : 1,
                              duration: AppMotion.of(
                                AppMotion.fast,
                                reduced: MediaQuery.of(context)
                                    .disableAnimations,
                              ),
                              curve: AppMotion.change,
                              sliver: sliver,
                            ),
                        ],
                      ),
                    ),
                    ScrollToTopButton(
                      controller: scrollController,
                      reserveNavSpace: widget.reserveNavSpace,
                    ),
                    SearchFilterButton(
                      activeCount: state.filters.activeCount,
                      visible: state.totalResults > 0 || state.filters.isActive,
                      onTap: () => showSearchFiltersSheet(context),
                      reserveNavSpace: widget.reserveNavSpace,
                    ),
                  ],
                );
              },
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
          child: ConnectivityErrorStateWidget(onRetry: cubit.retryIndex),
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
      // Los filtros se aplican a las secciones de resultados y a otros años.
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
      // La franja de filtros activos va bajo el primer encabezado de resultados.
      final strip = state.filters.isActive
          ? SearchActiveFiltersRow(
              count: state.filters.activeCount,
              onOpen: () => showSearchFiltersSheet(context),
              onClear: cubit.clearFilters,
            )
          : null;
      if (state.filters.isActive && shown.isEmpty && shownOthers.isEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: SearchFilteredEmptyWidget(
              summary: SearchFilterLabels.summary(state.filters),
              onClearFilters: cubit.clearFilters,
              onClearAll: cubit.clearAll,
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
              strip: strip,
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
              strip: shown.isEmpty ? strip : null,
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
            strip: strip,
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
    Widget? strip,
  }) {
    return [
      _padded(
        child: header,
        top: AppSpacing.xs,
        bottom: strip == null ? AppSpacing.s : 0,
      ),
      if (strip != null) _padded(child: strip, top: 0, bottom: AppSpacing.xs),
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
      // Los mismos filtros guían también los resultados de otros años.
      final service = cubit.filterService;
      final filters = state.filters;
      final pending = filters.engines.isEmpty
          ? 0
          : service.unanalyzedCount(status.results, filters, state.traits);
      final showStatus =
          filters.needsTraits && (state.isAnalyzing || pending > 0);
      return [
        _padded(
          child: SearchOtherYearsWidget(
            status: status,
            onCancel: cubit.cancelOtherYears,
            onOpen: (result) => _openResult(context, result),
            shown: service.apply(status.results, filters, state.traits),
            filtersActive: filters.isActive,
            onClearFilters: cubit.clearFilters,
            analysis: showStatus
                ? SearchAnalysisStatusWidget(
                    isAnalyzing: state.isAnalyzing,
                    analyzed: state.otherYearsAnalyzedCount,
                    total: state.otherYearsCandidates.length,
                    pending: pending,
                  )
                : null,
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
    final picks = _picksSlivers(context, state);
    if (state.recents.isEmpty && state.brands.isEmpty && picks.isEmpty) {
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
      if (widget.picksFirst) ...picks,
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
      if (!widget.picksFirst) ...picks,
      ..._feedSlivers(context, state),
      SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
    ];
  }

  // Feed bajo las sugerencias: una cuadrícula por página, el cargador o la nota de final.
  List<Widget> _feedSlivers(BuildContext context, SearchState state) {
    if (!_feedActive(state)) return const [];
    final cubit = context.read<SearchCubit>();
    final picks = cubit.picksFor(_picksSeed, count: widget.picksCount);
    if (picks.isEmpty) return const [];
    final scope = state.scope!;
    final resetKey = '${scope.key} feed $_picksSeed';
    const pageSize = SearchConfig.feedPageSize;
    final status = cubit.feedPage(
      _picksSeed,
      exclude: _shownKeys(picks),
      pageSize: 0,
    );
    return [
      // Una cuadrícula por página: la entrada en cascada vuelve a empezar en cada una.
      for (final start in List<int>.generate(
        (_feed.length / pageSize).ceil(),
        (page) => page * pageSize,
      ))
        SliverPadding(
          key: ValueKey('$resetKey page ${start ~/ pageSize}'),
          padding: EdgeInsets.fromLTRB(
            UiConfig.pageHorizontalPadding,
            start == 0 ? AppSpacing.m : ModelGridConfig.mainAxisSpacing,
            UiConfig.pageHorizontalPadding,
            0,
          ),
          sliver: widget.resultsGridBuilder(
            context,
            _feed.sublist(start, min(start + pageSize, _feed.length)),
            resetKey,
            (result) => _openResult(context, result),
          ),
        ),
      if (_feedLoading || (status.isBuilding && status.remaining == 0))
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: SearchConfig.feedFooterVerticalGap,
            ),
            child: Semantics(
              label: AppTexts.searchFeedLoadingSemanticLabel,
              child: const AppLoader(compact: true),
            ),
          ),
        )
      else if (_feed.isNotEmpty && status.isExhausted)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiConfig.pageHorizontalPadding,
              vertical: SearchConfig.feedFooterVerticalGap,
            ),
            child: Text(
              AppTexts.searchFeedEndNote,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ),
        ),
    ];
  }

  // "Sugerencias para ti": solo con el campo vacío y sin filtros activos.
  List<Widget> _picksSlivers(BuildContext context, SearchState state) {
    final builder = widget.picksBuilder;
    if (builder == null || state.query.isNotEmpty || state.filters.isActive) {
      return const [];
    }
    final scope = state.scope;
    final picks = context.read<SearchCubit>().picksFor(
      _picksSeed,
      count: widget.picksCount,
    );
    if (scope == null || picks.isEmpty) return const [];
    return [
      _padded(
        child: Text(AppTexts.searchPicksTitle, style: AppTextStyles.cardTitle),
        top: AppSpacing.m,
        bottom: AppSpacing.xs,
      ),
      SliverToBoxAdapter(
        child: builder(
          context,
          picks,
          '${scope.key} $_picksSeed',
          (result) => _openResult(context, result),
        ),
      ),
    ];
  }
}
