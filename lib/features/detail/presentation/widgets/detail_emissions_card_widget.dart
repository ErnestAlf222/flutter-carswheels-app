import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/detail_figure_grid_widget.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Tarjeta de CO₂ por ciclo; no aparece si la versión no trae ninguna cifra.
class DetailEmissionsCardWidget extends StatelessWidget {
  const DetailEmissionsCardWidget({super.key, required this.detail});

  final VehicleDetailEntity detail;

  @override
  Widget build(BuildContext context) {
    final city = detail.cityCo2GramsPerKilometer;
    final highway = detail.highwayCo2GramsPerKilometer;
    final combined = detail.co2GramsPerKilometer;
    final cells = [
      if (city != null)
        EfficiencyFigureData(
          AppTexts.gramsPerKilometerFigure(city),
          AppTexts.cityConsumptionLabel,
        ),
      if (highway != null)
        EfficiencyFigureData(
          AppTexts.gramsPerKilometerFigure(highway),
          AppTexts.highwayConsumptionLabel,
        ),
      if (combined != null)
        EfficiencyFigureData(
          AppTexts.gramsPerKilometerFigure(combined),
          AppTexts.combinedCycleLabel,
        ),
    ];
    if (cells.isEmpty) return const SizedBox.shrink();
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
            Text(AppTexts.emissionsTitle, style: AppTextStyles.sectionTitle),
            const SizedBox(height: UiConfig.efficiencyGridSpacing),
            DetailFigureGridWidget(cells: cells),
          ],
        ),
      ),
    );
  }
}
