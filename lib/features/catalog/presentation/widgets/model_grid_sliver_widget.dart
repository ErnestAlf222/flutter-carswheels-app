import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/model_grid_metrics.dart';

/// Sliver de cuadrícula cuyo alto de celda sale del ancho y de la escala de texto.
class ModelGridSliver extends StatelessWidget {
  const ModelGridSliver({
    super.key,
    required this.delegate,
    this.showBrandLabel = false,
    this.reserveActionRow = false,
  });

  final SliverChildDelegate delegate;

  /// Reserva el alto de la etiqueta de marca de la tarjeta.
  final bool showBrandLabel;

  /// Reserva el alto de la fila de acción que las tarjetas pueden llevar al pie.
  final bool reserveActionRow;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = ModelGridMetrics.cellWidth(constraints.crossAxisExtent);
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ModelGridConfig.columns,
            crossAxisSpacing: ModelGridConfig.crossAxisSpacing,
            mainAxisSpacing: ModelGridConfig.mainAxisSpacing,
            mainAxisExtent: ModelGridMetrics.cellHeight(
              width,
              scaler,
              showBrandLabel: showBrandLabel,
              reserveActionRow: reserveActionRow,
            ),
          ),
          delegate: delegate,
        );
      },
    );
  }
}
