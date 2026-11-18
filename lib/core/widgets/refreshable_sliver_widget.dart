import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/config/config.dart';

/// Atenúa un sliver y bloquea los toques mientras se actualiza.
class RefreshableSliverWidget extends StatelessWidget {
  const RefreshableSliverWidget({
    super.key,
    required this.isRefreshing,
    required this.sliver,
  });

  final bool isRefreshing;
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: AnimationConfig.dimDurationMilliseconds);
    return SliverIgnorePointer(
      ignoring: isRefreshing,
      sliver: SliverAnimatedOpacity(
        opacity: isRefreshing ? UiConfig.dimmedOpacity : 1.0,
        duration: duration,
        sliver: sliver,
      ),
    );
  }
}
