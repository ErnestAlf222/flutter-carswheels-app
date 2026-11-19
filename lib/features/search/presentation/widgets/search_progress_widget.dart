import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Barra lineal fina amarilla del avance del índice; no ocupa lugar en la lista.
class SearchProgressWidget extends StatelessWidget {
  const SearchProgressWidget({super.key, required this.progress});

  /// De 0 a 1; nulo cuando aún no hay avance medible.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppTexts.searchPreparingLabel,
      excludeSemantics: true,
      child: LinearProgressIndicator(
        value: progress,
        minHeight: SearchConfig.progressHeight,
        color: AppColors.accent,
        backgroundColor: AppColors.outline,
      ),
    );
  }
}
