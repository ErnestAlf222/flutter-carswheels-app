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

/// Pantalla de búsqueda: encabezado con campo, marcas fijas y resultados.
class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.onOpenResult,
    required this.resultsGridBuilder,
  });

  final SearchResultOpener onOpenResult;
  final SearchResultsGridBuilder resultsGridBuilder;

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
            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: SearchHeaderWidget(
                    scope: state.scope,
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: cubit.onQueryChanged,
                    onSubmitted: (_) => cubit.submit(),
                    onClear: cubit.clearQuery,
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SearchBrandSelectorDelegate(
                    brands: state.brands,
                    selectedBrand: state.brandFilter,
                    onSelectBrand: cubit.selectBrand,
                    onClear: cubit.clearBrand,
                    showProgress: state.isPreparing,
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
    if (state.results.isNotEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            UiConfig.pageHorizontalPadding,
            AppSpacing.xs,
            UiConfig.pageHorizontalPadding,
            AppSpacing.s,
          ),
          sliver: SliverToBoxAdapter(
            child: SearchResultsHeaderWidget(
              count: state.results.length,
              brand: state.brandFilter,
              truncated: state.isTruncated,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            UiConfig.pageHorizontalPadding,
            0,
            UiConfig.pageHorizontalPadding,
            bottomPadding,
          ),
          sliver: widget.resultsGridBuilder(
            context,
            state.results,
            state.resultsKey,
            (result) => _openResult(context, result),
          ),
        ),
      ];
    }
    final scope = state.scope;
    if (state.hasNoResults && scope != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: SearchNoResultsWidget(
              query: state.query,
              marketCode: scope.marketCode,
              year: scope.year,
              brand: state.brandFilter,
              onClearBrand: cubit.clearBrand,
            ),
          ),
        ),
      ];
    }
    // Índice aún en marcha: la barra amarilla indica el avance.
    return const [SliverToBoxAdapter(child: SizedBox.shrink())];
  }

  // Sin consulta ni marca: recientes en una fila, o un texto amable.
  List<Widget> _idleSlivers(
    BuildContext context,
    SearchState state,
    double bottomPadding,
  ) {
    final cubit = context.read<SearchCubit>();
    if (state.recents.isEmpty) {
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
