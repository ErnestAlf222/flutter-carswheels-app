import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/presentation/cubits/cubits.dart';

/// Mensaje breve de "ya está" o "lleno", en una píldora neutra.
class CompareNoticeWidget extends StatelessWidget {
  const CompareNoticeWidget({super.key, required this.notice});

  final CompareNotice notice;

  @override
  Widget build(BuildContext context) {
    final message = switch (notice) {
      CompareNotice.alreadyAdded => AppTexts.compareAlreadyAddedNotice,
      CompareNotice.full => AppTexts.compareFullNotice,
    };
    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.chipBackground,
          borderRadius: BorderRadius.circular(AppRadii.tile),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CompareConfig.noticeHorizontalPadding,
            vertical: CompareConfig.noticeVerticalPadding,
          ),
          child: Row(
            children: [
              const Icon(
                Symbols.info,
                size: CompareConfig.noticeIconSize,
                color: AppColors.ink,
              ),
              const SizedBox(width: CompareConfig.noticeIconGap),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.caption.copyWith(color: AppColors.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
