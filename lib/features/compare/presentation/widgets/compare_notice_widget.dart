import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/presentation/cubits/cubits.dart';

/// Mensaje breve del comparador (agregado, reemplazo, repetido), en una píldora neutra.
class CompareNoticeWidget extends StatelessWidget {
  const CompareNoticeWidget({
    super.key,
    required this.notice,
    this.subject,
    this.other,
  });

  final CompareNotice notice;

  /// Nombre del vehículo del mensaje, si lo lleva.
  final String? subject;

  /// Nombre del vehículo que salió, en el mensaje de reemplazo.
  final String? other;

  @override
  Widget build(BuildContext context) {
    final message = switch (notice) {
      CompareNotice.alreadyAdded => AppTexts.compareAlreadyAddedNotice,
      CompareNotice.full => AppTexts.compareFullNotice,
      CompareNotice.added => AppTexts.compareAddedNotice(subject ?? ''),
      CompareNotice.replaced => AppTexts.compareReplacedNotice(
        other ?? '',
        subject ?? '',
      ),
      CompareNotice.startedNew => AppTexts.compareStartedNewNotice(
        subject ?? '',
      ),
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
