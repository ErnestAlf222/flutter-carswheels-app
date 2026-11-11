import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/navigation/presentation/cubits/cubits.dart';

/// Marco de la app: contenido (la transición la hace cada ruta) y menú encima.
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  // Rutas en el mismo orden que los botones del menú.
  static const List<String> _routes = [
    RoutesConfig.home,
    RoutesConfig.search,
    RoutesConfig.compare,
    RoutesConfig.favorites,
    RoutesConfig.settings,
  ];

  static const List<FloatingNavItemModel> _items = [
    FloatingNavItemModel(icon: Symbols.home, label: AppTexts.navHomeLabel),
    FloatingNavItemModel(icon: Symbols.search, label: AppTexts.navSearchLabel),
    FloatingNavItemModel(
      icon: Symbols.compare_arrows,
      label: AppTexts.navCompareLabel,
    ),
    FloatingNavItemModel(
      icon: Symbols.favorite,
      label: AppTexts.navFavoritesLabel,
    ),
    FloatingNavItemModel(
      icon: Symbols.person,
      label: AppTexts.navSettingsLabel,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final int index = _routes.indexOf(location);
    return BlocProvider(
      create: (_) => NavVisibilityCubit(),
      child: Builder(
        builder: (context) => Scaffold(
          body: Stack(
            children: [
              NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) {
                  final double? delta = notification.scrollDelta;
                  if (delta != null) {
                    context.read<NavVisibilityCubit>().onScroll(delta);
                  }
                  return false;
                },
                child: child,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom:
                    NavConfig.bottomMargin +
                    MediaQuery.of(context).padding.bottom,
                child: Center(
                  child: BlocBuilder<NavVisibilityCubit, NavVisibilityState>(
                    builder: (context, state) => FloatingNavBar(
                      items: _items,
                      currentIndex: index < 0 ? 0 : index,
                      visible: state.visible,
                      onSelected: (selected) => context.go(_routes[selected]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
