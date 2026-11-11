import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../config/core_config.dart';

/// Entrada sutil (aparece subiendo) escalonada por índice.
class AnimatedEntryWidget extends StatelessWidget {
  const AnimatedEntryWidget({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return child;
    }
    return FadeInUp(
      duration: const Duration(
        milliseconds: AnimationConfig.fadeDurationMilliseconds,
      ),
      delay: Duration(
        milliseconds: index * AnimationConfig.entryDelayStepMilliseconds,
      ),
      child: child,
    );
  }
}
