import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Barra de esqueleto con pulso suave para los datos que aún no llegan.
class SummarySkeletonBarWidget extends StatelessWidget {
  const SummarySkeletonBarWidget({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      width: width,
      height: UiConfig.summarySkeletonBarHeight,
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(UiConfig.summarySkeletonBarHeight),
      ),
    );
    if (MediaQuery.of(context).disableAnimations) return bar;
    return Pulse(
      infinite: true,
      to: UiConfig.skeletonPulseScale,
      duration: const Duration(
        milliseconds: AnimationConfig.skeletonPulseMilliseconds,
      ),
      child: bar,
    );
  }
}
