import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/model_grid_metrics.dart';

/// Silueta de una tarjeta de la cuadrícula; replica foto y filas de la tarjeta real.
class ModelGridCardSkeletonWidget extends StatelessWidget {
  const ModelGridCardSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(
            aspectRatio: ModelGridConfig.photoAspectRatio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadii.card),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                ModelGridConfig.textHorizontalPadding,
                ModelGridConfig.textTopPadding,
                ModelGridConfig.textHorizontalPadding,
                ModelGridConfig.textBottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: ModelGridMetrics.nameHeight(scaler),
                    width: double.infinity,
                    child: const Align(
                      alignment: Alignment.topLeft,
                      child: FractionallySizedBox(
                        widthFactor: ModelGridConfig.skeletonNameBarFraction,
                        child: SkeletonBarWidget(
                          width: double.infinity,
                          height: ModelGridConfig.skeletonNameBarHeight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: ModelGridConfig.classTopGap),
                  SizedBox(
                    height: ModelGridMetrics.classHeight(scaler),
                    width: double.infinity,
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: ModelGridConfig.skeletonClassBarFraction,
                        child: SkeletonBarWidget(
                          width: double.infinity,
                          height: ModelGridConfig.skeletonClassBarHeight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: ModelGridConfig.consumptionTopGap),
                  SkeletonBarWidget(
                    width: ModelGridConfig.skeletonConsumptionBarWidth,
                    height: ModelGridMetrics.consumptionHeight(scaler),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return Semantics(excludeSemantics: true, child: card);
  }
}
