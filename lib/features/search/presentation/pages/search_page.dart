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

/// Pantalla de búsqueda de marcas y modelos.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.onOpenResult});

  final SearchResultOpener onOpenResult;

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

  // Mantiene el campo igual a la consulta cuando cambia sin teclear (recientes, marcas).
  void _syncField(BuildContext context, SearchState state) {
    if (_controller.text == state.query) return;
    _controller.value = TextEditingValue(
      text: state.query,
      selection: TextSelection.collapsed(offset: state.query.length),
    );
  }

  void _openResult(BuildContext context, SearchResultEntity result) {
    final cubit = context.read<SearchCubit>();
    if (result.isBrandOnly) {
      cubit.selectBrand(result.brand);
      return;
    }
    cubit.registerResultTap();
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
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<SearchCubit, SearchState>(
                  buildWhen: (previous, current) =>
                      previous.scope != current.scope,
                  builder: (context, state) => _Header(scope: state.scope),
                ),
                const SizedBox(height: AppSpacing.m),
                SearchFieldWidget(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: cubit.onQueryChanged,
                  onSubmitted: (_) => cubit.submit(),
                  onClear: cubit.clearQuery,
                ),
                const SizedBox(height: AppSpacing.s),
                BlocBuilder<SearchCubit, SearchState>(
                  buildWhen: (previous, current) =>
                      previous.indexStatus != current.indexStatus ||
                      previous.indexFailed != current.indexFailed,
                  builder: (context, state) => _IndexNotice(state: state),
                ),
                Expanded(
                  child: BlocBuilder<SearchCubit, SearchState>(
                    builder: (context, state) =>
                        _Body(state: state, onOpenResult: _openResult),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Encabezado con el título y el chip de contexto.
class _Header extends StatelessWidget {
  const _Header({required this.scope});

  final SearchScopeEntity? scope;

  @override
  Widget build(BuildContext context) {
    final current = scope;
    return Row(
      children: [
        Expanded(
          child: Text(
            AppTexts.searchPageTitle,
            style: AppTextStyles.screenTitle,
          ),
        ),
        if (current != null)
          SearchContextChipWidget(
            marketCode: current.marketCode,
            year: current.year,
          ),
      ],
    );
  }
}

/// Progreso del índice o aviso de índice parcial; nunca tapa los resultados.
class _IndexNotice extends StatelessWidget {
  const _IndexNotice({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    if (state.isPreparing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: SearchProgressWidget(progress: state.indexStatus?.progress),
      );
    }
    if (state.isPartial) {
      return InlineMessageWidget(
        message: AppTexts.searchPartialMessage,
        actionLabel: AppTexts.retryButtonLabel,
        onAction: context.read<SearchCubit>().retryIndex,
      );
    }
    return const SizedBox.shrink();
  }
}

/// Cuerpo: error, recientes y marcas, resultados o sin resultados.
class _Body extends StatelessWidget {
  const _Body({required this.state, required this.onOpenResult});

  final SearchState state;
  final void Function(BuildContext, SearchResultEntity) onOpenResult;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    final bottomPadding =
        NavConfig.footprint +
        MediaQuery.paddingOf(context).bottom +
        AppSpacing.m;
    if (state.hasBlockingError) {
      return ErrorStateWidget(onRetry: cubit.retryIndex);
    }
    if (!state.hasQuery) {
      return _Idle(state: state, bottomPadding: bottomPadding);
    }
    if (state.results.isNotEmpty) {
      return ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(top: AppSpacing.xs, bottom: bottomPadding),
        itemCount: state.results.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (context, index) {
          final result = state.results[index];
          final row = SearchResultRowWidget(
            key: ValueKey(result),
            result: result,
            onTap: () => onOpenResult(context, result),
          );
          if (index >= SearchConfig.animatedResultCount) return row;
          return AnimatedEntryWidget(index: index, child: row);
        },
      );
    }
    final scope = state.scope;
    if (state.hasNoResults && scope != null) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SearchNoResultsWidget(
          query: state.query,
          marketCode: scope.marketCode,
          year: scope.year,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Sin consulta: recientes y marcas del índice, o un texto breve.
class _Idle extends StatelessWidget {
  const _Idle({required this.state, required this.bottomPadding});

  final SearchState state;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    final hasRecents = state.recents.isNotEmpty;
    final hasBrands = state.quickBrands.isNotEmpty;
    if (!hasRecents && !hasBrands) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Text(
            AppTexts.searchIdleHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ),
      );
    }
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(top: AppSpacing.xs, bottom: bottomPadding),
      children: [
        if (hasRecents)
          SearchRecentsWidget(
            recents: state.recents,
            onSelect: cubit.useRecent,
            onRemove: (recent) => cubit.removeRecentSearch(recent.key),
            onClearAll: cubit.clearRecentSearches,
          ),
        if (hasRecents && hasBrands)
          const SizedBox(height: SearchConfig.sectionGap),
        if (hasBrands)
          SearchQuickBrandsWidget(
            brands: state.quickBrands,
            onSelect: cubit.selectBrand,
          ),
      ],
    );
  }
}
