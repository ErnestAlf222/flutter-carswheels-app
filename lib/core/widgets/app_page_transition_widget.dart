import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';

/// Única puerta para las transiciones entre pantallas.
class AppPageTransition extends StatelessWidget {
  const AppPageTransition({super.key, required this.child});

  final Widget child;

  /// Duración de la transición entre pantallas.
  static const Duration duration = Duration(
    milliseconds: AnimationConfig.pageTransitionMilliseconds,
  );

  /// Transición para páginas de ruta (el contenido de un ShellRoute no se duplica).
  static Widget routeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.of(context).disableAnimations) return child;
    return _fadeThrough(child, animation, secondaryAnimation);
  }

  static Widget _fadeThrough(
    Widget child,
    Animation<double> primary,
    Animation<double> secondary,
  ) {
    return FadeThroughTransition(
      animation: primary,
      secondaryAnimation: secondary,
      fillColor: Colors.transparent,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool still = MediaQuery.of(context).disableAnimations;
    return PageTransitionSwitcher(
      duration: still ? Duration.zero : duration,
      transitionBuilder: (child, primary, secondary) =>
          _fadeThrough(child, primary, secondary),
      child: child,
    );
  }
}
