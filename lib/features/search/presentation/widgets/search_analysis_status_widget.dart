import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// "Analizando X de N…" con el loader compacto, o cuántos faltan por analizar.
class SearchAnalysisStatusWidget extends StatelessWidget {
  const SearchAnalysisStatusWidget({
    super.key,
    required this.isAnalyzing,
    required this.analyzed,
    required this.total,
    required this.pending,
  });

  final bool isAnalyzing;
  final int analyzed;
  final int total;

  /// Resultados sin analizar que afectan a lo que se muestra.
  final int pending;

  @override
  Widget build(BuildContext context) {
    if (!isAnalyzing && pending == 0) return const SizedBox.shrink();
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: SearchConfig.filterStatusMinHeight,
      ),
      child: Row(
        children: [
          if (isAnalyzing) ...[
            const AppLoader(compact: true),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Text(
              isAnalyzing
                  ? AppTexts.searchFiltersAnalyzingLabel(analyzed, total)
                  : AppTexts.searchFiltersPendingLabel(pending),
              key: const ValueKey('search-analysis-status'),
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}
