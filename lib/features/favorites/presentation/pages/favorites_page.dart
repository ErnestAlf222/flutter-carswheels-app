import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/domain/domain.dart';
import 'package:cars_wheels_app/features/favorites/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/favorites/presentation/widgets/favorites_empty_widget.dart';
import 'package:cars_wheels_app/features/favorites/presentation/widgets/favorites_market_filter_widget.dart';

/// Arma el sliver con la cuadrícula de tarjetas de favoritos; lo implementa la capa app.
///
/// [onOpen] abre Detalle del favorito y [onRemove] lo quita con "Deshacer".
typedef FavoritesGridBuilder = Widget Function(
  BuildContext context,
  List<FavoriteEntity> favorites,
  ValueChanged<FavoriteEntity> onOpen,
  ValueChanged<FavoriteEntity> onRemove,
);

/// Pantalla Favoritos: encabezado con el contador, filtro por mercado y rejilla.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({
    super.key,
    required this.selectorBuilder,
    required this.gridBuilder,
    required this.onOpen,
    required this.onExplore,
  });

  /// Selector de mercado y año del encabezado; lo implementa la capa app.
  final WidgetBuilder selectorBuilder;
  final FavoritesGridBuilder gridBuilder;

  /// Abre Detalle con los datos guardados, sin tocar el mercado global.
  final void Function(BuildContext context, FavoriteEntity favorite) onOpen;

  /// Lleva a Inicio desde el estado vacío.
  final void Function(BuildContext context) onExplore;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // Único estado: el mercado del filtro; nulo es "Todos".
  String? _market;

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        NavConfig.footprint +
        MediaQuery.paddingOf(context).bottom +
        ModelGridConfig.listBottomGap;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        buildWhen: (previous, current) =>
            previous is! FavoritesLoaded ||
            current is! FavoritesLoaded ||
            previous.favorites != current.favorites,
        builder: (context, state) {
          final favorites = state is FavoritesLoaded
              ? state.favorites
              : const <FavoriteEntity>[];
          final markets = _marketsOf(favorites);
          // Un filtro sin favoritos (se quitaron todos) vuelve a "Todos".
          final selected = markets.contains(_market) ? _market : null;
          final shown = selected == null
              ? favorites
              : [
                  for (final favorite in favorites)
                    if (favorite.marketCode == selected) favorite,
                ];
          return CustomScrollView(
            slivers: [
              const StatusBarBandSliver(),
              SliverToBoxAdapter(
                child: _Header(
                  count: favorites.length,
                  selectorBuilder: widget.selectorBuilder,
                ),
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
                // Con un solo mercado el filtro no hace falta.
                if (markets.length > 1)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      UiConfig.pageHorizontalPadding,
                      FavoritesConfig.listTopGap,
                      UiConfig.pageHorizontalPadding,
                      FavoritesConfig.filterBottomGap,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: FavoritesMarketFilterWidget(
                        marketCodes: markets,
                        selected: selected,
                        onSelected: (code) => setState(() => _market = code),
                      ),
                    ),
                  )
                else
                  const SliverToBoxAdapter(
                    child: SizedBox(height: FavoritesConfig.listTopGap),
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
                  ),
                ),
              ],
              SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
            ],
          );
        },
      ),
    );
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

/// Encabezado tinta: título con el contador de guardados y el selector.
class _Header extends StatelessWidget {
  const _Header({required this.count, required this.selectorBuilder});

  final int count;
  final WidgetBuilder selectorBuilder;

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
                  Text(
                    AppTexts.favoritesCountLabel(count),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.onDarkCaption,
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
