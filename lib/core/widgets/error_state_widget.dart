import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/l10n/l10n.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';
import 'package:cars_wheels_app/core/widgets/accent_button_widget.dart';
import 'package:cars_wheels_app/core/widgets/solid_background_widget.dart';

/// Estado de error con mensaje y botón para reintentar.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SolidBackgroundWidget(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Symbols.error_outline,
              size: UiConfig.iconSize,
              color: AppColors.mutedText,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(AppTexts.errorStateTitle, style: AppTextStyles.bodyStrong),
            const SizedBox(height: AppSpacing.m),
            AccentButton(label: AppTexts.retryButtonLabel, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
