import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/l10n/l10n.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';
import 'package:cars_wheels_app/core/widgets/accent_button_widget.dart';

/// Estado de error con mensaje y botón para reintentar.
///
/// Con [offline] explica que falta la conexión en vez de hablar de un error.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.onRetry,
    this.offline = false,
  });

  final VoidCallback onRetry;

  /// Verdadero cuando la causa es la falta de conexión a internet.
  final bool offline;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            offline ? Symbols.cloud_off : Symbols.error_outline,
            size: UiConfig.iconSize,
            color: AppColors.mutedText,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            offline ? AppTexts.offlineStateTitle : AppTexts.errorStateTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyStrong,
          ),
          if (offline) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiConfig.pageHorizontalPadding,
              ),
              child: Text(
                AppTexts.offlineStateBody,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          AccentButton(label: AppTexts.retryButtonLabel, onPressed: onRetry),
        ],
      ),
    );
  }
}
