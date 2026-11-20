import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_grid_row_widget.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_version_pill_widget.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_version_sheet_widget.dart';

/// Una pastilla de versión bajo cada espacio ocupado, alineada con su vehículo.
class CompareVersionPillsRowWidget extends StatelessWidget {
  const CompareVersionPillsRowWidget({
    super.key,
    required this.selection,
    required this.versionsSource,
  });

  final CompareSelectionEntity selection;

  /// Versiones de cada modelo; las resuelve la capa app.
  final CompareVersionsSource versionsSource;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: CompareConfig.versionPillTopGap),
      child: BlocBuilder<CompareTableCubit, CompareTableState>(
        builder: (context, table) => IntrinsicHeight(
          child: CompareGridRowWidget(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            cellBuilder: (index) {
              if (index >= selection.length) return const SizedBox.shrink();
              final slot = selection.slots[index];
              final label = _labelOf(slot, table.of(slot));
              return CompareVersionPillWidget(
                label: label,
                semanticLabel: AppTexts.compareVersionPillSemanticLabel(
                  slot.modelName,
                  label,
                ),
                onTap: () => showCompareVersionSheet(
                  context,
                  slot: slot,
                  source: versionsSource,
                  onSelected: (key) =>
                      context.read<CompareCubit>().changeVersion(slot, key),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Sin versión elegida es la predeterminada; con una, su nombre legible.
  String _labelOf(CompareSlotEntity slot, CompareColumnState column) {
    final key = slot.versionKey;
    if (key == null) return AppTexts.compareVersionDefaultLabel;
    return column is CompareColumnLoaded
        ? column.detail.versionLabel ?? key
        : key;
  }
}
