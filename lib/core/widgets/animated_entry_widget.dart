import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';

/// Entrada sutil (aparece subiendo) escalonada por índice.
class AnimatedEntryWidget extends StatelessWidget {
  const AnimatedEntryWidget({
    super.key,
    required this.index,
    required this.child,
    this.stepMilliseconds = AnimationConfig.entryDelayStepMilliseconds,
  });

  final int index;

  /// Retardo entre un índice y el siguiente.
  final int stepMilliseconds;
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
      delay: Duration(milliseconds: index * stepMilliseconds),
      child: child,
    );
  }
}
