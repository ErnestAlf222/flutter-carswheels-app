import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Encabezado de resultados: "N resultados" en overline, la marca y el aviso de tope.
class SearchResultsHeaderWidget extends StatelessWidget {
  const SearchResultsHeaderWidget({
    super.key,
    required this.count,
    this.brand,
    this.truncated = false,
  });

  final int count;

  /// Marca filtrada; nula si se busca en todas.
  final String? brand;

  /// Se alcanzó el tope de resultados.
  final bool truncated;

  @override
  Widget build(BuildContext context) {
    final current = brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.searchResultsCountLabel(count).toUpperCase(),
          style: AppTextStyles.label,
        ),
        if (current != null)
          Text(
            current,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle,
          ),
        if (truncated)
          Text(
            AppTexts.searchResultsTruncatedLabel(count),
            style: AppTextStyles.caption,
          ),
      ],
    );
  }
}
