import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Tarjeta con tres cifras: consumo (o motor), costo anual y seguridad.
class DetailStatsCardWidget extends StatelessWidget {
  const DetailStatsCardWidget({super.key, required this.detail});

  final VehicleDetailEntity detail;

  @override
  Widget build(BuildContext context) {
    final cells = [_consumptionCell(), _costCell(), _safetyCell()];
    final semanticLabel = cells
        .map((cell) => '${cell.figure}, ${cell.caption}')
        .join(AppTexts.semanticListSeparator);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConfig.detailStatsSideMargin,
        AppSpacing.s,
        UiConfig.detailStatsSideMargin,
        0,
      ),
      child: Semantics(
        container: true,
        label: semanticLabel,
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: UiConfig.detailStatsVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.soft,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int index = 0; index < cells.length; index++) ...[
                  if (index > 0) const _StatDivider(),
                  Expanded(child: _StatCell(data: cells[index])),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Consumo si lo hay; si no, el tipo de motor; si no, sin dato.
  _StatData _consumptionCell() {
    final combined = detail.combinedKmPerLiter;
    if (combined != null) {
      return _StatData(
        figure: AppTexts.kmPerLiterFigure(combined),
        caption: AppTexts.detailConsumptionCaption,
      );
    }
    final labels = const PowertrainLabelsResolver().labelsForPowertrain(
      detail.powertrain,
    );
    if (labels.isEmpty) {
      return const _StatData(
        figure: AppTexts.noDataLabel,
        caption: AppTexts.detailConsumptionCaption,
      );
    }
    return _StatData(
      figure: labels.join(AppTexts.semanticListSeparator),
      caption: AppTexts.detailPowertrainCaption,
      isLabel: true,
    );
  }

  _StatData _costCell() {
    final cost = detail.annualFuelCostUsd;
    return _StatData(
      figure: cost == null
          ? AppTexts.noDataLabel
          : AppTexts.annualCostLabel(cost),
      caption: AppTexts.detailAnnualCostCaption,
    );
  }

  // La seguridad de NHTSA llega en otra parte; por ahora sin dato.
  _StatData _safetyCell() => const _StatData(
    figure: AppTexts.noDataLabel,
    caption: AppTexts.detailSafetyCaption,
  );
}

/// Lo que muestra una celda; isLabel indica texto de motor en vez de cifra.
class _StatData {
  const _StatData({
    required this.figure,
    required this.caption,
    this.isLabel = false,
  });

  final String figure;
  final String caption;
  final bool isLabel;
}

/// Una celda: la cifra y su etiqueta debajo.
class _StatCell extends StatelessWidget {
  const _StatCell({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.figure,
            maxLines: data.isLabel ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: data.isLabel
                ? AppTextStyles.cardTitle
                : AppTextStyles.statFigure,
          ),
          Text(
            data.caption,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(height: 1.3),
          ),
        ],
      ),
    );
  }
}

/// Línea vertical entre celdas.
class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: UiConfig.detailStatDividerWidth,
      child: ColoredBox(color: AppColors.line),
    );
  }
}
