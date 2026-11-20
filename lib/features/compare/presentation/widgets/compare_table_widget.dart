import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_column_status_widget.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_grid_row_widget.dart';

/// Cuerpo de la tabla: carga por columna y las secciones con sus filas.
///
/// Cada valor queda bajo su vehículo, con el ancho de los espacios de arriba.
class CompareTableWidget extends StatelessWidget {
  const CompareTableWidget({
    super.key,
    required this.slots,
    required this.table,
    required this.onRetry,
    this.builder = const CompareTableBuilder(),
  });

  final List<CompareSlotEntity> slots;
  final CompareTableState table;
  final ValueChanged<CompareSlotEntity> onRetry;
  final CompareTableBuilder builder;

  @override
  Widget build(BuildContext context) {
    final sections = builder.build(
      marketCode: slots.first.marketCode,
      columns: table.detailsOf(slots),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (CompareColumnStatusWidget.isNeeded(slots, table)) ...[
          const SizedBox(height: CompareConfig.statusTopGap),
          CompareColumnStatusWidget(
            slots: slots,
            table: table,
            onRetry: onRetry,
          ),
        ],
        for (final section in sections) ...[
          const SizedBox(height: CompareConfig.sectionTopGap),
          Text(section.title, style: AppTextStyles.sectionTitle),
          const SizedBox(height: CompareConfig.sectionTitleGap),
          for (final row in section.rows) _Row(row: row, slots: slots),
        ],
      ],
    );
  }
}

/// Una fila: la etiqueta pequeña arriba y un valor bajo cada vehículo.
class _Row extends StatelessWidget {
  const _Row({required this.row, required this.slots});

  final CompareTableRowEntity row;
  final List<CompareSlotEntity> slots;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CompareConfig.rowGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: Text(row.label, style: AppTextStyles.compareRowLabel),
          ),
          const SizedBox(height: CompareConfig.rowLabelGap),
          CompareGridRowWidget(
            cellBuilder: (index) {
              final cell = index < row.cells.length ? row.cells[index] : null;
              if (cell == null) return const SizedBox.shrink();
              return _Value(
                cell: cell,
                semanticLabel: AppTexts.compareCellSemanticLabel(
                  row.label,
                  AppTexts.compareColumnHeaderLabel(
                    slots[index].brand,
                    slots[index].modelName,
                  ),
                  cell.text,
                  isBest: cell.isBest,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Valor de una celda; el mejor va en una pastilla de relleno accentTint.
class _Value extends StatelessWidget {
  const _Value({required this.cell, required this.semanticLabel});

  final CompareTableCellEntity cell;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    // Todos llevan el mismo relleno, así el texto no se mueve al resaltar.
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CompareConfig.bestPillHorizontalPadding,
        vertical: CompareConfig.bestPillVerticalPadding,
      ),
      child: Text(
        cell.text,
        style: cell.isBest
            ? AppTextStyles.compareBestValue
            : AppTextStyles.compareValue,
      ),
    );
    return Semantics(
      container: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Align(
        alignment: Alignment.topLeft,
        // El relleno se corre hacia afuera: el texto queda en el borde izquierdo
        // de la columna, igual que la etiqueta, la banda y el espacio de arriba.
        child: Transform.translate(
          offset: const Offset(-CompareConfig.bestPillHorizontalPadding, 0),
          child: cell.isBest
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.accentTint,
                    borderRadius: BorderRadius.circular(
                      CompareConfig.bestPillRadius,
                    ),
                  ),
                  child: content,
                )
              : content,
        ),
      ),
    );
  }
}
