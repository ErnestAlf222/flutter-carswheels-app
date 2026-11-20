import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Aviso discreto del índice en obra: "Indexando… X de N marcas". Con [onRetry]
/// (índice parcial) suma el botón amarillo "Reintentar".
class SearchPartialNoticeWidget extends StatelessWidget {
  const SearchPartialNoticeWidget({
    super.key,
    required this.indexed,
    required this.total,
    this.onRetry,
  });

  final int indexed;
  final int total;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppTexts.searchIndexingNotice(indexed, total),
              key: const ValueKey('search-indexing-notice'),
              style: AppTextStyles.caption,
            ),
          ),
          if (retry != null) ...[
            const SizedBox(width: AppSpacing.xs),
            AccentButton(
              label: AppTexts.retryButtonLabel,
              onPressed: retry,
              compact: true,
            ),
          ],
        ],
      ),
    );
  }
}
