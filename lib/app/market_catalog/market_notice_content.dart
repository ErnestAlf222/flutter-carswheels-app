import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Bandera en un aro amarillo y dos líneas de texto.
class MarketNoticeContent extends StatelessWidget {
  const MarketNoticeContent({
    super.key,
    required this.flag,
    required this.title,
    required this.body,
  });

  final String flag;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MarketConfig.noticeHorizontalPadding,
        vertical: MarketConfig.noticeVerticalPadding,
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent,
                  width: MarketConfig.noticeFlagRingWidth,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs / 2),
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: MarketConfig.noticeFlagSize),
                ),
              ),
            ),
          ),
          const SizedBox(width: MarketConfig.noticeGap),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: AppColors.onDark,
                  ),
                ),
                Text(
                  body,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedOnDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
