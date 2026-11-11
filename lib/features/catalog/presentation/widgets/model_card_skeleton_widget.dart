import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Silueta de una tarjeta de modelo mientras cargan los datos.
class ModelCardSkeletonWidget extends StatelessWidget {
  const ModelCardSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: UiConfig.modelThumbnailSize,
            height: UiConfig.modelThumbnailSize,
            decoration: BoxDecoration(
              color: AppColors.tint,
              borderRadius: BorderRadius.circular(AppRadii.tile),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBar(widthFraction: UiConfig.skeletonLongBarFraction),
                SizedBox(height: AppSpacing.xs),
                _SkeletonBar(widthFraction: UiConfig.skeletonShortBarFraction),
              ],
            ),
          ),
        ],
      ),
    );
    final content = MediaQuery.of(context).disableAnimations
        ? card
        : Pulse(
            infinite: true,
            to: UiConfig.skeletonPulseScale,
            duration: const Duration(
              milliseconds: AnimationConfig.skeletonPulseMilliseconds,
            ),
            child: card,
          );
    return Semantics(excludeSemantics: true, child: content);
  }
}

/// Barra gris que imita una línea de texto.
class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.widthFraction});

  final double widthFraction;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFraction,
      child: Container(
        height: UiConfig.skeletonBarHeight,
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(UiConfig.skeletonBarHeight),
        ),
      ),
    );
  }
}
