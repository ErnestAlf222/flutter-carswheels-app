import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_grid_row_widget.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_version_label_widget.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_version_pill_widget.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_version_sheet_widget.dart';

/// Una pastilla de versión bajo cada espacio ocupado, alineada con su vehículo.
class CompareVersionPillsRowWidget extends StatelessWidget {
  const CompareVersionPillsRowWidget({
    super.key,
    required this.selection,
    required this.versionsSource,
    required this.versionLabeler,
  });

  final CompareSelectionEntity selection;

  /// Versiones de cada modelo; las resuelve la capa app.
  final CompareVersionsSource versionsSource;

  /// Nombre legible de la versión guardada; lo resuelve la capa app.
  final CompareVersionLabeler versionLabeler;

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
              final column = table.of(slot);
              Widget pill(String label) => CompareVersionPillWidget(
                label: label,
                isLoading: _isLoading(slot, column),
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
              final known = _knownLabelOf(slot, column);
              if (known != null) return pill(known);
              // Sin etiqueta en la columna, se pide a la capa app en vez de mostrar la clave.
              return CompareVersionLabelBuilder(
                slot: slot,
                labeler: versionLabeler,
                builder: (_, label) => pill(label),
              );
            },
          ),
        ),
      ),
    );
  }

  // Con una versión elegida, su nombre aún no llegó mientras la columna carga.
  bool _isLoading(CompareSlotEntity slot, CompareColumnState column) =>
      slot.versionKey != null && column is CompareColumnLoading;

  // Etiqueta ya a la mano: predeterminada, la de la columna o "—" mientras carga.
  String? _knownLabelOf(CompareSlotEntity slot, CompareColumnState column) {
    if (slot.versionKey == null) return AppTexts.compareVersionDefaultLabel;
    if (column is CompareColumnLoading) return AppTexts.missingValueLabel;
    return column is CompareColumnLoaded ? column.detail.versionLabel : null;
  }
}
