import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../config/core_config.dart';
import '../l10n/core_l10n.dart';
import '../theme/core_theme.dart';

/// Estado vacío con icono y mensaje.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeIn(
        duration: const Duration(
          milliseconds: AnimationConfig.fadeDurationMilliseconds,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Symbols.search_off,
              size: UiConfig.iconSize,
              color: AppColors.subtle,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(AppTexts.emptyStateTitle, style: AppTextStyles.bodyStrong),
          ],
        ),
      ),
    );
  }
}
