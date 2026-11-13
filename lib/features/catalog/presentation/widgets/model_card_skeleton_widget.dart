import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Silueta de una tarjeta de modelo mientras cargan los datos.
class ModelCardSkeletonWidget extends StatelessWidget {
  const ModelCardSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.fromLTRB(
        UiConfig.modelCardLeftPadding,
        AppSpacing.xs,
        UiConfig.modelCardRightPadding,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: UiConfig.modelPhotoWidth,
            height: UiConfig.modelPhotoHeight,
            decoration: BoxDecoration(
              color: AppColors.tint,
              borderRadius: BorderRadius.circular(AppRadii.tile),
            ),
          ),
          const SizedBox(width: UiConfig.modelCardGap),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FractionBar(widthFraction: UiConfig.skeletonLongBarFraction),
                SizedBox(height: AppSpacing.xs),
                _FractionBar(widthFraction: UiConfig.skeletonShortBarFraction),
              ],
            ),
          ),
          const SizedBox(width: UiConfig.modelCardGap),
          const SizedBox(
            width: UiConfig.modelConsumptionColumnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonBarWidget(
                  width: UiConfig.summarySkeletonLongBarWidth,
                  height: UiConfig.summarySkeletonBarHeight,
                ),
                SizedBox(height: AppSpacing.xs),
                SkeletonBarWidget(
                  width: UiConfig.summarySkeletonShortBarWidth,
                  height: UiConfig.summarySkeletonBarHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Semantics(excludeSemantics: true, child: card);
  }
}

/// Barra de texto cuyo ancho es una fracción del espacio libre.
class _FractionBar extends StatelessWidget {
  const _FractionBar({required this.widthFraction});

  final double widthFraction;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFraction,
      child: const SkeletonBarWidget(
        width: double.infinity,
        height: UiConfig.skeletonBarHeight,
      ),
    );
  }
}
