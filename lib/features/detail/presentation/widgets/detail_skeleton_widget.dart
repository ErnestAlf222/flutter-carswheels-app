import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Siluetas de la cápsula, el botón de versión, las cifras y las filas.
class DetailSkeletonWidget extends StatelessWidget {
  const DetailSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              UiConfig.detailInfoSideMargin,
              AppSpacing.xs,
              UiConfig.detailInfoSideMargin,
              0,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: SkeletonBarWidget(
                width: UiConfig.detailSkeletonChipWidth,
                height: UiConfig.detailSkeletonChipHeight,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              UiConfig.detailSelectorSideMargin,
              AppSpacing.s,
              UiConfig.detailSelectorSideMargin,
              0,
            ),
            child: SkeletonBarWidget(
              width: double.infinity,
              height: UiConfig.detailSelectorHeight,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              UiConfig.detailStatsSideMargin,
              AppSpacing.s,
              UiConfig.detailStatsSideMargin,
              0,
            ),
            child: SkeletonBarWidget(
              width: double.infinity,
              height: UiConfig.detailSkeletonStatsHeight,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UiConfig.detailInfoSideMargin,
              AppSpacing.m,
              UiConfig.detailInfoSideMargin,
              0,
            ),
            child: Column(
              children: [
                for (
                  int index = 0;
                  index < UiConfig.detailSkeletonRowCount;
                  index++
                ) ...[
                  if (index > 0) const SizedBox(height: AppSpacing.s),
                  const SkeletonBarWidget(
                    width: double.infinity,
                    height: UiConfig.detailSkeletonRowHeight,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
