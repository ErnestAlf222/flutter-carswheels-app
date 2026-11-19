import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/detail_figure_grid_widget.dart';
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: AppColors.outline,
            width: UiConfig.detailCardBorderWidth,
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppTexts.efficiencyTitle, style: AppTextStyles.sectionTitle),
            if (cells.isNotEmpty) ...[
              const SizedBox(height: UiConfig.efficiencyGridSpacing),
              DetailFigureGridWidget(cells: cells),
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
  List<EfficiencyFigureData> _cells() {
    final city = detail.cityKmPerLiter;
    final highway = detail.highwayKmPerLiter;
    final totalRange = detail.totalRangeKilometers;
    final electricRange = detail.electricRangeKilometers;
    final electricConsumption = detail.electricConsumptionKwhPer100Kilometers;
    final hybridGas = detail.hybridGasKmPerLiter;
    final co2 = detail.co2GramsPerKilometer;
    return [
      if (city != null)
        EfficiencyFigureData(_kmPerLiter(city), AppTexts.cityConsumptionLabel),
      if (highway != null)
        EfficiencyFigureData(
          _kmPerLiter(highway),
          AppTexts.highwayConsumptionLabel,
        ),
      if (totalRange != null)
        EfficiencyFigureData(
          AppTexts.kilometersFigure(totalRange),
          AppTexts.totalRangeLabel,
        ),
      if (electricRange != null)
        EfficiencyFigureData(
          AppTexts.kilometersFigure(electricRange),
          AppTexts.electricRangeLabel,
        ),
      if (electricConsumption != null)
        EfficiencyFigureData(
          AppTexts.kwhPer100KmFigure(electricConsumption),
          AppTexts.electricConsumptionLabel,
        ),
      if (hybridGas != null)
        EfficiencyFigureData(
          _kmPerLiter(hybridGas),
          AppTexts.hybridGasConsumptionLabel,
        ),
      if (co2 != null)
        EfficiencyFigureData(
          AppTexts.gramsPerKilometerFigure(co2),
          AppTexts.co2Label,
        ),
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

/// Etiqueta y puntuación de una fila.
class _ScoreData {
  const _ScoreData(this.label, this.score);

  final String label;
  final int score;
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
        color: filled ? AppColors.accent : AppColors.outline,
        borderRadius: BorderRadius.circular(
          UiConfig.efficiencyScoreSegmentRadius,
        ),
      ),
    );
  }
}
