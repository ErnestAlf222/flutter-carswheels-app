import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/cubits.dart';
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
    final cells = [_consumptionCell(), _costCell(), _safetyCell()];
    final semanticLabel = cells
        .map((cell) => cell.semanticLabel ?? '${cell.figure}, ${cell.caption}')
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

  // Estrellas NHTSA: esqueleto al cargar y "—" si no hay dato o falló.
  _StatData _safetyCell() {
    final current = safety;
    if (current is SafetyLoading<GroupSafetyEntity>) {
      return const _StatData(
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
        return _StatData(
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
    return const _StatData(
      figure: AppTexts.noDataLabel,
      caption: AppTexts.detailSafetyCaption,
    );
  }
}

/// Lo que muestra una celda; isLabel indica texto de motor en vez de cifra.
class _StatData {
  const _StatData({
    required this.figure,
    required this.caption,
    this.isLabel = false,
    this.isLoading = false,
    this.extra,
    this.semanticLabel,
  });

  final String figure;
  final String caption;
  final bool isLabel;

  /// Cifra aún en camino: se dibuja un esqueleto en su lugar.
  final bool isLoading;

  /// Contenido bajo la cifra, como las estrellas.
  final Widget? extra;

  /// Etiqueta de accesibilidad propia; sin ella se usan cifra y título.
  final String? semanticLabel;
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
          if (data.isLoading)
            const SkeletonBarWidget(
              width: UiConfig.safetySkeletonFigureWidth,
              height: UiConfig.safetySkeletonFigureHeight,
            )
          else
            Text(
              data.figure,
              maxLines: data.isLabel ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: data.isLabel
                  ? AppTextStyles.cardTitle
                  : AppTextStyles.statFigure,
            ),
          ?data.extra,
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
