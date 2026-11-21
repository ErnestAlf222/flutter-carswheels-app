import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/connectivity/connectivity.dart';
import 'package:cars_wheels_app/features/favorites/domain/domain.dart';
import 'package:cars_wheels_app/features/favorites/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/favorites/presentation/widgets/favorites_empty_widget.dart';
import 'package:cars_wheels_app/features/favorites/presentation/widgets/favorites_market_filter_widget.dart';
import 'package:cars_wheels_app/features/favorites/presentation/widgets/favorites_selection_bar_widget.dart';
import 'package:cars_wheels_app/features/favorites/presentation/widgets/favorites_sort_widget.dart';

/// Lo que la rejilla necesita del modo de selección; nulo fuera de él.
class FavoritesSelectionView {
  const FavoritesSelectionView({
    required this.selectedKeys,
    required this.blockOf,
    required this.onToggle,
  });

  /// Claves de los favoritos elegidos.
  final Set<String> selectedKeys;

  /// Por qué un favorito no se puede elegir; [FavoriteSelectionBlock.none] si se puede.
  final FavoriteSelectionBlock Function(FavoriteEntity favorite) blockOf;

  /// Elige o quita un favorito; la página decide si la regla lo permite.
  final ValueChanged<FavoriteEntity> onToggle;
}

/// Arma el sliver con el mosaico de tarjetas de favoritos; lo implementa la capa app.
///
/// [onOpen] abre Detalle del favorito y [onRemove] lo quita con "Deshacer". Con
/// [selection] las tarjetas muestran su casilla en lugar del corazón.
typedef FavoritesGridBuilder = Widget Function(
  BuildContext context,
  List<FavoriteEntity> favorites,
  ValueChanged<FavoriteEntity> onOpen,
  ValueChanged<FavoriteEntity> onRemove,
  FavoritesSelectionView? selection,
);

/// Cuántos autos más caben en la comparación de cada mercado; lo da la capa app.
typedef FavoritesCapacityLoader = Future<Map<String, int>> Function(
  BuildContext context,
);

/// Agrega los favoritos a la comparación de su mercado; verdadero si lo logró.
typedef FavoritesCompareAction = Future<bool> Function(
  BuildContext context,
  List<FavoriteEntity> favorites,
);

/// Pantalla Favoritos: encabezado con el contador, orden, filtro por mercado y mosaico.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({
    super.key,
    required this.selectorBuilder,
    required this.gridBuilder,
    required this.onOpen,
    required this.onExplore,
    required this.loadCompareCapacity,
    required this.onCompare,
    required this.onGoToCompare,
  });

  /// Selector de mercado y año del encabezado; lo implementa la capa app.
  final WidgetBuilder selectorBuilder;
  final FavoritesGridBuilder gridBuilder;

  /// Abre Detalle con los datos guardados, sin tocar el mercado global.
  final void Function(BuildContext context, FavoriteEntity favorite) onOpen;

  /// Lleva a Inicio desde el estado vacío.
  final void Function(BuildContext context) onExplore;

  /// Capacidad restante de la comparación por mercado; se pide al entrar al modo de selección.
  final FavoritesCapacityLoader loadCompareCapacity;

  /// Agrega lo elegido a la comparación y navega a ella.
  final FavoritesCompareAction onCompare;

  /// Lleva a la pestaña Comparar (acción de "Tu comparación está llena").
  final void Function(BuildContext context) onGoToCompare;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // Estado de la pantalla: mercado del filtro (nulo es "Todos") y la selección.
  String? _market;
  bool _selecting = false;
  List<String> _selectedKeys = const [];
  Map<String, int>? _capacity;
  bool _fullTapped = false;

  FavoriteSelectionPolicy get _policy =>
      FavoriteSelectionPolicy(remainingByMarket: _capacity ?? const {});

  Future<void> _enterSelection() async {
    setState(() {
      _selecting = true;
      _selectedKeys = const [];
      _fullTapped = false;
    });
    final capacity = await widget.loadCompareCapacity(context);
    if (mounted) setState(() => _capacity = capacity);
  }

  void _exitSelection() => setState(() {
    _selecting = false;
    _selectedKeys = const [];
    _fullTapped = false;
  });

  // Elige o quita; lo que la regla bloquea no cambia nada (la tarjeta ya se ve atenuada).
  void _toggle(FavoriteEntity favorite, List<FavoriteEntity> all) {
    if (_selectedKeys.contains(favorite.key)) {
      setState(() {
        _selectedKeys = [
          for (final key in _selectedKeys)
            if (key != favorite.key) key,
        ];
        _fullTapped = false;
      });
      return;
    }
    final selected = _selectedOf(all);
    final block = _policy.blockFor(favorite, selected);
    switch (block) {
      case FavoriteSelectionBlock.none:
        setState(() {
          _selectedKeys = [..._selectedKeys, favorite.key];
          _fullTapped = false;
        });
      case FavoriteSelectionBlock.noCapacity:
        setState(() => _fullTapped = true);
      case FavoriteSelectionBlock.otherMarket ||
          FavoriteSelectionBlock.limitReached:
        break;
    }
  }

  Future<void> _compare(List<FavoriteEntity> selected) async {
    final done = await widget.onCompare(context, selected);
    if (done && mounted) _exitSelection();
  }

  // Favoritos elegidos, en el orden en que se eligieron.
  List<FavoriteEntity> _selectedOf(List<FavoriteEntity> all) => [
    for (final key in _selectedKeys)
      ...all.where((favorite) => favorite.key == key),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        NavConfig.footprint +
        MediaQuery.paddingOf(context).bottom +
        ModelGridConfig.listBottomGap +
        (_selecting ? FavoritesConfig.selectionListReserve : 0);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        buildWhen: (previous, current) =>
            previous is! FavoritesLoaded ||
            current is! FavoritesLoaded ||
            previous.favorites != current.favorites ||
            previous.sortMode != current.sortMode,
        builder: (context, state) {
          final favorites = state is FavoritesLoaded
              ? state.favorites
              : const <FavoriteEntity>[];
          final markets = _marketsOf(favorites);
          // Un filtro sin favoritos (se quitaron todos) vuelve a "Todos".
          final selected = markets.contains(_market) ? _market : null;
          final sortMode = state is FavoritesLoaded
              ? state.sortMode
              : FavoriteSortMode.recent;
          // El orden se aplica a la lista que queda tras el filtro de mercado.
          final shown = FavoriteSorter.sort([
            for (final favorite in favorites)
              if (selected == null || favorite.marketCode == selected) favorite,
          ], sortMode);
          final chosen = _selectedOf(favorites);
          final selecting = _selecting && favorites.isNotEmpty;
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  const StatusBarBandSliver(),
                  SliverToBoxAdapter(
                    child: _Header(
                      count: favorites.length,
                      selectorBuilder: widget.selectorBuilder,
                      selecting: selecting,
                      canSelect: favorites.isNotEmpty,
                      onSelect: _enterSelection,
                      onExit: _exitSelection,
                    ),
                  ),
                  // Aquí dice además que lo guardado sigue disponible sin conexión.
                  const ConnectivityBandSliver(
                    offlineLabel: AppTexts.offlineFavoritesBandLabel,
                  ),
                  if (state is FavoritesLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppLoader(compact: true),
                    )
                  else if (favorites.isEmpty)
                    SliverToBoxAdapter(
                      child: FavoritesEmptyWidget(
                        onExplore: () => widget.onExplore(context),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        UiConfig.pageHorizontalPadding,
                        FavoritesConfig.listTopGap,
                        UiConfig.pageHorizontalPadding,
                        FavoritesConfig.filterBottomGap,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FavoritesSortWidget(
                              selected: sortMode,
                              onSelected: context
                                  .read<FavoritesCubit>()
                                  .setSortMode,
                            ),
                            // Con un solo mercado el filtro no hace falta.
                            if (markets.length > 1)
                              FavoritesMarketFilterWidget(
                                marketCodes: markets,
                                selected: selected,
                                onSelected: (code) =>
                                    setState(() => _market = code),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: UiConfig.pageHorizontalPadding,
                      ),
                      sliver: widget.gridBuilder(
                        context,
                        shown,
                        (favorite) => widget.onOpen(context, favorite),
                        (favorite) =>
                            context.read<FavoritesCubit>().remove(favorite),
                        selecting
                            ? FavoritesSelectionView(
                                selectedKeys: _selectedKeys.toSet(),
                                blockOf: (favorite) =>
                                    _policy.blockFor(favorite, chosen),
                                onToggle: (favorite) =>
                                    _toggle(favorite, favorites),
                              )
                            : null,
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
                ],
              ),
              Positioned(
                left: UiConfig.pageHorizontalPadding,
                right: UiConfig.pageHorizontalPadding,
                // Sobre la barra de navegación, sin tapar su píldora.
                bottom:
                    NavConfig.footprint + MediaQuery.paddingOf(context).bottom,
                child: _animatedBar(selecting, favorites, chosen),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _animatedBar(
    bool selecting,
    List<FavoriteEntity> favorites,
    List<FavoriteEntity> chosen,
  ) {
    final still = MediaQuery.of(context).disableAnimations;
    return AnimatedSwitcher(
      duration: still ? Duration.zero : AppMotion.fast,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: selecting
          ? _bar(favorites, chosen)
          : const SizedBox.shrink(key: ValueKey('no-bar')),
    );
  }

  Widget _bar(List<FavoriteEntity> favorites, List<FavoriteEntity> chosen) {
    final note = _noteFor(favorites, chosen);
    return FavoritesSelectionBarWidget(
      key: const ValueKey('selection-bar'),
      count: chosen.length,
      onCompare: _policy.canCompare(chosen) ? () => _compare(chosen) : null,
      note: note.text,
      noteActionLabel: note.withAction
          ? FavoritesTexts.goToCompareAction
          : null,
      onNoteAction: note.withAction
          ? () => widget.onGoToCompare(context)
          : null,
    );
  }

  // Una sola nota a la vez, por prioridad.
  ({String? text, bool withAction}) _noteFor(
    List<FavoriteEntity> favorites,
    List<FavoriteEntity> chosen,
  ) {
    if (_fullTapped) {
      return (text: FavoritesTexts.compareFullNote, withAction: true);
    }
    final locked = _policy.lockedMarket(chosen);
    if (locked != null &&
        favorites.any((favorite) => favorite.marketCode != locked)) {
      return (text: FavoritesTexts.otherMarketNote, withAction: false);
    }
    if (locked != null && chosen.length >= _policy.remaining(locked)) {
      return (
        text: FavoritesTexts.capacityNote(_policy.remaining(locked)),
        withAction: false,
      );
    }
    if (_policy.needsMoreCars(chosen)) {
      return (text: FavoritesTexts.needTwoNote, withAction: false);
    }
    return (text: null, withAction: false);
  }

  // Mercados presentes, con EE. UU. primero y México después.
  List<String> _marketsOf(List<FavoriteEntity> favorites) => [
    for (final code in const [
      MarketConfig.unitedStatesCode,
      MarketConfig.mexicoCode,
    ])
      if (favorites.any((favorite) => favorite.marketCode == code)) code,
  ];
}

/// Encabezado tinta: título, contador, la acción "Seleccionar" y el selector.
class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.selectorBuilder,
    required this.selecting,
    required this.canSelect,
    required this.onSelect,
    required this.onExit,
  });

  final int count;
  final WidgetBuilder selectorBuilder;
  final bool selecting;
  final bool canSelect;
  final VoidCallback onSelect;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return HeroHeaderWidget(
      includeTopInset: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiConfig.pageHorizontalPadding,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Con texto grande el título se encoge en vez de desbordar.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppTexts.favoritesPageTitle,
                      maxLines: 1,
                      style: AppTextStyles.onDarkScreenTitle,
                    ),
                  ),
                  const SizedBox(height: FavoritesConfig.headerSubtitleGap),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          AppTexts.favoritesCountLabel(count),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.onDarkCaption,
                        ),
                      ),
                      if (canSelect) ...[
                        const SizedBox(width: FavoritesConfig.selectionBarGap),
                        _SelectAction(
                          selecting: selecting,
                          onSelect: onSelect,
                          onExit: onExit,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            selectorBuilder(context),
          ],
        ),
      ),
    );
  }
}

/// "Seleccionar" en el encabezado; en modo de selección es la X que sale de él.
class _SelectAction extends StatelessWidget {
  const _SelectAction({
    required this.selecting,
    required this.onSelect,
    required this.onExit,
  });

  final bool selecting;
  final VoidCallback onSelect;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: selecting
          ? FavoritesTexts.exitSelectionSemanticLabel
          : FavoritesTexts.selectAction,
      excludeSemantics: true,
      onTap: selecting ? onExit : onSelect,
      child: InkWell(
        onTap: selecting ? onExit : onSelect,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: FavoritesConfig.checkboxTouchSize,
            minWidth: FavoritesConfig.checkboxTouchSize,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selecting ? Symbols.close : Symbols.check_circle,
                size: FavoritesConfig.selectionActionIconSize,
                color: AppColors.onDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
