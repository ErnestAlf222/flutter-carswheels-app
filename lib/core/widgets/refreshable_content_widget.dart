import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';

/// Atenúa el contenido y bloquea los toques mientras se actualiza.
class RefreshableContentWidget extends StatelessWidget {
  const RefreshableContentWidget({
    super.key,
    required this.isRefreshing,
    required this.child,
  });

  final bool isRefreshing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: AnimationConfig.dimDurationMilliseconds);
    return IgnorePointer(
      ignoring: isRefreshing,
      child: AnimatedOpacity(
        opacity: isRefreshing ? UiConfig.dimmedOpacity : 1.0,
        duration: duration,
        child: child,
      ),
    );
  }
}
