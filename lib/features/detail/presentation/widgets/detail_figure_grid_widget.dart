import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Cifra y etiqueta de una celda.
class EfficiencyFigureData {
  const EfficiencyFigureData(this.figure, this.label);

  final String figure;
  final String label;
}

/// Cuadrícula de dos columnas; una celda sola ocupa la mitad.
class DetailFigureGridWidget extends StatelessWidget {
  const DetailFigureGridWidget({super.key, required this.cells});

  final List<EfficiencyFigureData> cells;

  static const int _columns = 2;

  @override
  Widget build(BuildContext context) {
    final rowCount = (cells.length / _columns).ceil();
    return Column(
      children: [
        for (int row = 0; row < rowCount; row++) ...[
          if (row > 0) const SizedBox(height: UiConfig.efficiencyGridSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int column = 0; column < _columns; column++) ...[
                if (column > 0)
                  const SizedBox(width: UiConfig.efficiencyGridSpacing),
                Expanded(
                  child: row * _columns + column < cells.length
                      ? _FigureCell(data: cells[row * _columns + column])
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Una celda: la cifra y su etiqueta debajo.
class _FigureCell extends StatelessWidget {
  const _FigureCell({required this.data});

  final EfficiencyFigureData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data.figure, style: AppTextStyles.efficiencyFigure),
        Text(data.label, style: AppTextStyles.caption),
      ],
    );
  }
}
