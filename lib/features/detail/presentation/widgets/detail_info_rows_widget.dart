import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Filas de clase, combustible y tracción, y la fila de recalls.
class DetailInfoRowsWidget extends StatelessWidget {
  const DetailInfoRowsWidget({
    super.key,
    this.classLabel,
    this.fuelLabel,
    this.driveLabel,
    this.recallsLabel,
  });

  final String? classLabel;
  final String? fuelLabel;
  final String? driveLabel;
  final String? recallsLabel;

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
          _RecallsRow(value: recallsLabel),
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

/// Fila de avisos de seguridad; todavía sin acción.
class _RecallsRow extends StatelessWidget {
  const _RecallsRow({required this.value});

  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: UiConfig.detailRecallsTopMargin),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppTexts.detailRecallsLabel,
              style: AppTextStyles.infoValue,
            ),
          ),
          Text(
            value ?? AppTexts.noDataLabel,
            style: AppTextStyles.recallsValue,
          ),
          const Icon(
            Symbols.chevron_right,
            size: UiConfig.iconSize,
            color: AppColors.subtle,
          ),
        ],
      ),
    );
  }
}
