import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../l10n/core_l10n.dart';
import '../theme/core_theme.dart';

/// Estado de error con mensaje y botón para reintentar.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.error_outline, color: AppColors.subtle),
          const SizedBox(height: AppSpacing.xs),
          Text(AppTexts.errorStateTitle, style: AppTextStyles.bodyStrong),
          const SizedBox(height: AppSpacing.m),
          FilledButton(
            onPressed: onRetry,
            child: const Text(AppTexts.retryButtonLabel),
          ),
        ],
      ),
    );
  }
}
