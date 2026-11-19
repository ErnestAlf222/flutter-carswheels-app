import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/app/market_catalog/market_search_detail_args_builder.dart';
import 'package:cars_wheels_app/app/market_catalog/search_market_year_selector.dart';
import 'package:cars_wheels_app/app/search_results/search_results_grid.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/navigation/navigation.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:cars_wheels_app/features/settings/settings.dart';

/// Página de ruta con la transición de AppPageTransition.
CustomTransitionPage<void> _page(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppPageTransition.duration,
      transitionsBuilder: AppPageTransition.routeTransition,
    );

/// Página de ruta de las pantallas de flujo, fuera del menú flotante.
CustomTransitionPage<void> _flowPage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppPageTransition.duration,
      transitionsBuilder: AppPageTransition.flowRouteTransition,
    );

/// Abre Detalle desde un resultado de búsqueda, por la ruta de flujo.
Future<void> openSearchResultInDetail(
  BuildContext context,
  SearchResultEntity result,
) async {
  final router = GoRouter.of(context);
  final builder = MarketSearchDetailArgsBuilder(
    getModelGroups: context.read<GetModelGroupsUseCase>(),
    currentMarket: () => context.read<MarketCubit>().market,
  );
  final args = await builder.build(result);
  if (args == null || !context.mounted) return;
  await router.push<void>(RoutesConfig.detail, extra: args);
}

/// Cambia a la sección de búsqueda con el teclado enfocado.
void openSearchFromHome(BuildContext context) {
  context.read<SearchCubit>().requestFocus();
  context.go(RoutesConfig.search);
}

/// Crea el router: un marco con las cinco pantallas principales.
GoRouter buildAppRouter() => GoRouter(
  initialLocation: RoutesConfig.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          MainShellPage(location: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: RoutesConfig.home,
          pageBuilder: (context, state) =>
              _page(state, const HomePage(onSearchTap: openSearchFromHome)),
        ),
        GoRoute(
          path: RoutesConfig.search,
          pageBuilder: (context, state) => _page(
            state,
            const SearchPage(
              onOpenResult: openSearchResultInDetail,
              resultsGridBuilder: buildSearchResultsGrid,
              selectorBuilder: buildSearchMarketYearSelector,
            ),
          ),
        ),
        GoRoute(
          path: RoutesConfig.compare,
          pageBuilder: (context, state) => _page(state, const ComparePage()),
        ),
        GoRoute(
          path: RoutesConfig.favorites,
          pageBuilder: (context, state) => _page(state, const FavoritesPage()),
        ),
        GoRoute(
          path: RoutesConfig.settings,
          pageBuilder: (context, state) => _page(state, const SettingsPage()),
        ),
      ],
    ),
    GoRoute(
      path: RoutesConfig.detail,
      redirect: (context, state) =>
          state.extra is DetailArgsEntity ? null : RoutesConfig.home,
      pageBuilder: (context, state) =>
          _flowPage(state, DetailPage(args: state.extra! as DetailArgsEntity)),
    ),
    GoRoute(
      path: RoutesConfig.photoViewer,
      redirect: (context, state) =>
          _hasViewerArgs(state.extra) ? null : RoutesConfig.home,
      pageBuilder: (context, state) => _page(
        state,
        PhotoViewerPage(args: state.extra! as PhotoViewerArgsEntity),
      ),
    ),
  ],
);

// El visor necesita al menos una foto que mostrar.
bool _hasViewerArgs(Object? extra) =>
    extra is PhotoViewerArgsEntity && extra.photos.isNotEmpty;
