import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/core.dart';
import '../../features/catalog/catalog.dart';
import '../../features/compare/compare.dart';
import '../../features/favorites/favorites.dart';
import '../../features/navigation/navigation.dart';
import '../../features/search/search.dart';
import '../../features/settings/settings.dart';

/// Página de ruta con la transición de AppPageTransition.
CustomTransitionPage<void> _page(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppPageTransition.duration,
      transitionsBuilder: AppPageTransition.routeTransition,
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
  ],
);
