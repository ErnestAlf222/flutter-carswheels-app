import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/navigation/navigation.dart';
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
          pageBuilder: (context, state) => _page(state, const HomePage()),
        ),
        GoRoute(
          path: RoutesConfig.search,
          pageBuilder: (context, state) => _page(state, const SearchPage()),
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
  ],
);
