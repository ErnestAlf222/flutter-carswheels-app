import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';

/// Filas de clase, combustible y tracción, y la fila de recalls.
class DetailInfoRowsWidget extends StatelessWidget {
  const DetailInfoRowsWidget({
    super.key,
    this.classLabel,
    this.fuelLabel,
    this.driveLabel,
    this.recalls = const SafetyEmpty<RecallSummaryEntity>(),
    this.onRecallsTap,
    this.beforeRecalls,
  });

  final String? classLabel;
  final String? fuelLabel;
  final String? driveLabel;

  /// Recalls NHTSA; cargan aparte y solo afectan a su fila.
  final SafetyLoad<RecallSummaryEntity> recalls;

  /// Abre la lista de recalls; solo se usa si hay al menos uno.
  final VoidCallback? onRecallsTap;

  /// Contenido opcional entre las filas de datos y la fila de recalls.
  final Widget? beforeRecalls;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConfig.detailInfoSideMargin,
        AppSpacing.xs,
        UiConfig.detailInfoSideMargin,
        0,
      ),
      child: Column(
        children: [
          _InfoRow(label: AppTexts.detailClassRowLabel, value: classLabel),
          _InfoRow(label: AppTexts.detailFuelRowLabel, value: fuelLabel),
          _InfoRow(label: AppTexts.detailDriveRowLabel, value: driveLabel),
          ?beforeRecalls,
          _RecallsRow(recalls: recalls, onTap: onRecallsTap),
        ],
      ),
    );
  }
}

/// Una fila de dato con su línea punteada debajo.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: UiConfig.detailInfoRowVerticalPadding,
          ),
          child: Row(
            children: [
              Text(label, style: AppTextStyles.infoLabel),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Text(
                  value ?? AppTexts.noDataLabel,
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.infoValue,
                ),
              ),
            ],
          ),
        ),
        const DashedDividerWidget(),
      ],
    );
  }
}

/// Fila de avisos de seguridad; abre la lista solo si hay al menos uno.
class _RecallsRow extends StatelessWidget {
  const _RecallsRow({required this.recalls, required this.onTap});

  final SafetyLoad<RecallSummaryEntity> recalls;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final current = recalls;
    final loading = current is SafetyLoading<RecallSummaryEntity>;
    // Nulo o error es "—"; el cero solo llega con la lista confirmada vacía.
    final count = current is SafetyData<RecallSummaryEntity>
        ? current.value.count
        : null;
    final value = count == null
        ? AppTexts.noDataLabel
        : count == 0
        ? AppTexts.noRecallsLabel
        : AppTexts.recallsCountLabel(count);
    final tappable = count != null && count > 0 && onTap != null;
    final row = Padding(
      padding: const EdgeInsets.only(top: UiConfig.detailRecallsTopMargin),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppTexts.detailRecallsLabel,
              style: AppTextStyles.infoValue,
            ),
          ),
          if (loading)
            const SkeletonBarWidget(
              width: UiConfig.recallsSkeletonWidth,
              height: UiConfig.recallsSkeletonHeight,
            )
          else
            Text(value, style: AppTextStyles.recallsValue),
          // El chevron solo aparece si la fila es tocable.
          if (tappable)
            const Icon(
              Symbols.chevron_right,
              size: UiConfig.iconSize,
              color: AppColors.subtle,
            ),
        ],
      ),
    );
    return Semantics(
      container: true,
      button: tappable,
      label: loading ? null : AppTexts.recallsRowSemanticLabel(value),
      excludeSemantics: !loading,
      child: tappable ? InkWell(onTap: onTap, child: row) : row,
    );
  }
}
