import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Tarjeta de consumo y emisiones con las cifras que existan y las puntuaciones.
class DetailEfficiencyCardWidget extends StatelessWidget {
  const DetailEfficiencyCardWidget({super.key, required this.detail});

  final VehicleDetailEntity detail;

  @override
  Widget build(BuildContext context) {
    final cells = _cells();
    final scores = _scores();
    if (cells.isEmpty && scores.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(UiConfig.efficiencyCardPadding),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppTexts.efficiencyTitle, style: AppTextStyles.sectionTitle),
            if (cells.isNotEmpty) ...[
              const SizedBox(height: UiConfig.efficiencyGridSpacing),
              _FigureGrid(cells: cells),
            ],
            for (final score in scores) ...[
              const SizedBox(height: UiConfig.efficiencyGridSpacing),
              _ScoreRow(data: score),
            ],
          ],
        ),
      ),
    );
  }

  // Solo las celdas con dato, en el orden de la tarjeta.
  List<_FigureData> _cells() {
    final city = detail.cityKmPerLiter;
    final highway = detail.highwayKmPerLiter;
    final totalRange = detail.totalRangeKilometers;
    final electricRange = detail.electricRangeKilometers;
    final electricConsumption = detail.electricConsumptionKwhPer100Kilometers;
    final hybridGas = detail.hybridGasKmPerLiter;
    final co2 = detail.co2GramsPerKilometer;
    return [
      if (city != null)
        _FigureData(_kmPerLiter(city), AppTexts.cityConsumptionLabel),
      if (highway != null)
        _FigureData(_kmPerLiter(highway), AppTexts.highwayConsumptionLabel),
      if (totalRange != null)
        _FigureData(
          AppTexts.kilometersFigure(totalRange),
          AppTexts.totalRangeLabel,
        ),
      if (electricRange != null)
        _FigureData(
          AppTexts.kilometersFigure(electricRange),
          AppTexts.electricRangeLabel,
        ),
      if (electricConsumption != null)
        _FigureData(
          AppTexts.kwhPer100KmFigure(electricConsumption),
          AppTexts.electricConsumptionLabel,
        ),
      if (hybridGas != null)
        _FigureData(_kmPerLiter(hybridGas), AppTexts.hybridGasConsumptionLabel),
      if (co2 != null)
        _FigureData(AppTexts.gramsPerKilometerFigure(co2), AppTexts.co2Label),
    ];
  }

  List<_ScoreData> _scores() {
    final fuel = detail.fuelScore;
    final emissions = detail.emissionsScore;
    return [
      if (fuel != null) _ScoreData(AppTexts.fuelScoreLabel, fuel),
      if (emissions != null)
        _ScoreData(AppTexts.emissionsScoreLabel, emissions),
    ];
  }

  String _kmPerLiter(double value) =>
      '${AppTexts.kmPerLiterFigure(value)} ${AppTexts.kmPerLiterUnit}';
}

/// Cifra y etiqueta de una celda.
class _FigureData {
  const _FigureData(this.figure, this.label);

  final String figure;
  final String label;
}

/// Etiqueta y puntuación de una fila.
class _ScoreData {
  const _ScoreData(this.label, this.score);

  final String label;
  final int score;
}

/// Cuadrícula de dos columnas; una celda sola ocupa la mitad.
class _FigureGrid extends StatelessWidget {
  const _FigureGrid({required this.cells});

  final List<_FigureData> cells;

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

  final _FigureData data;

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

/// Fila de una puntuación: etiqueta a la izquierda y barra a la derecha.
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.data});

  final _ScoreData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(data.label, style: AppTextStyles.infoLabel)),
        const SizedBox(width: AppSpacing.m),
        _ScoreBar(score: data.score),
      ],
    );
  }
}

/// Barra de segmentos con los primeros N rellenos.
class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppTexts.scoreSemanticLabel(score),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (
            int index = 0;
            index < UiConfig.efficiencyScoreSegmentCount;
            index++
          ) ...[
            if (index > 0)
              const SizedBox(width: UiConfig.efficiencyScoreSegmentGap),
            _ScoreSegment(filled: index < score),
          ],
        ],
      ),
    );
  }
}

/// Un segmento de la barra.
class _ScoreSegment extends StatelessWidget {
  const _ScoreSegment({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: UiConfig.efficiencyScoreSegmentWidth,
      height: UiConfig.efficiencyScoreSegmentHeight,
      decoration: BoxDecoration(
        gradient: filled ? AppGradients.primary : null,
        color: filled ? null : AppColors.scoreSegmentEmpty,
        borderRadius: BorderRadius.circular(
          UiConfig.efficiencyScoreSegmentRadius,
        ),
      ),
    );
  }
}
