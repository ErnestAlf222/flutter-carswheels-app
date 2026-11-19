import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Aviso discreto de índice parcial con el botón amarillo "Reintentar".
class SearchPartialNoticeWidget extends StatelessWidget {
  const SearchPartialNoticeWidget({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppTexts.searchPartialMessage,
            style: AppTextStyles.caption,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        AccentButton(
          label: AppTexts.retryButtonLabel,
          onPressed: onRetry,
          compact: true,
        ),
      ],
    );
  }
}
