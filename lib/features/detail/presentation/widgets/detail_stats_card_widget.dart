import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/detail_figures_card_widget.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/safety_stars_widget.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Tarjeta con tres cifras: consumo (o motor), costo anual y seguridad.
class DetailStatsCardWidget extends StatelessWidget {
  const DetailStatsCardWidget({
    super.key,
    required this.detail,
    this.safety = const SafetyEmpty<GroupSafetyEntity>(),
  });

  final VehicleDetailEntity detail;

  /// Estrellas NHTSA del grupo; cargan aparte y solo afectan su celda.
  final SafetyLoad<GroupSafetyEntity> safety;

  @override
  Widget build(BuildContext context) {
    return DetailFiguresCardWidget(
      cells: [_consumptionCell(), _costCell(), _safetyCell()],
    );
  }

  // Consumo si lo hay; si no, el tipo de motor; si no, sin dato.
  DetailFigureData _consumptionCell() {
    final combined = detail.combinedKmPerLiter;
    if (combined != null) {
      return DetailFigureData(
        figure: AppTexts.kmPerLiterFigure(combined),
        caption: AppTexts.detailConsumptionCaption,
      );
    }
    final labels = const PowertrainLabelsResolver().labelsForPowertrain(
      detail.powertrain,
    );
    if (labels.isEmpty) {
      return const DetailFigureData(
        figure: AppTexts.noDataLabel,
        caption: AppTexts.detailConsumptionCaption,
      );
    }
    return DetailFigureData(
      figure: labels.join(AppTexts.semanticListSeparator),
      caption: AppTexts.detailPowertrainCaption,
      isLabel: true,
    );
  }

  DetailFigureData _costCell() {
    final cost = detail.annualFuelCostUsd;
    return DetailFigureData(
      figure: cost == null
          ? AppTexts.noDataLabel
          : AppTexts.annualCostLabel(cost),
      caption: AppTexts.detailAnnualCostCaption,
    );
  }

  // Estrellas NHTSA: esqueleto al cargar y "—" si no hay dato o falló.
  DetailFigureData _safetyCell() {
    final current = safety;
    if (current is SafetyLoading<GroupSafetyEntity>) {
      return const DetailFigureData(
        figure: AppTexts.noDataLabel,
        caption: AppTexts.detailSafetyCaption,
        isLoading: true,
        semanticLabel: AppTexts.detailSafetyCaption,
      );
    }
    if (current is SafetyData<GroupSafetyEntity>) {
      final max = current.value.maxOverall;
      if (max != null) {
        final min = current.value.minOverall ?? max;
        return DetailFigureData(
          figure: AppTexts.safetyFigureLabel(min, max),
          caption: AppTexts.detailSafetyCaption,
          extra: SafetyStarsWidget(
            stars: max,
            note: min == max
                ? null
                : AppTexts.safetyRatedVersionsNote(current.value.ratedCount),
          ),
          semanticLabel: AppTexts.safetyRatingSemanticLabel(
            min,
            max,
            current.value.ratedCount,
          ),
        );
      }
    }
    return const DetailFigureData(
      figure: AppTexts.noDataLabel,
      caption: AppTexts.detailSafetyCaption,
    );
  }
}
