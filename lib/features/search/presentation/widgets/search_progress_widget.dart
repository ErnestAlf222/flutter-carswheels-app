import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Barra lineal delgada y texto corto mientras se prepara el índice.
class SearchProgressWidget extends StatelessWidget {
  const SearchProgressWidget({super.key, required this.progress});

  /// De 0 a 1; nulo cuando aún no hay avance medible.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(SearchConfig.progressHeight),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: SearchConfig.progressHeight,
            color: AppColors.link,
            backgroundColor: AppColors.line,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(AppTexts.searchPreparingLabel, style: AppTextStyles.caption),
      ],
    );
  }
}
