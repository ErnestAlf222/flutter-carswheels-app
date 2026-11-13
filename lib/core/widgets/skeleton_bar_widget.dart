import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';

/// Barra de esqueleto con pulso suave para los datos que aún no llegan.
class SkeletonBarWidget extends StatelessWidget {
  const SkeletonBarWidget({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(AppRadii.skeletonBar),
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
