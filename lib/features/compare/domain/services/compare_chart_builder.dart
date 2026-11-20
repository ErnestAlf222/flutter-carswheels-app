import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/l10n/l10n.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_chart_entity.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_table_cell_entity.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_table_row_entity.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_table_section_entity.dart';

/// Elige las métricas graficables a partir de las filas de la tabla.
///
/// No recalcula nada: toma la cifra y el mejor valor que ya marcó la tabla.
/// Una métrica entra solo si al menos [CompareConfig.minSlots] vehículos
/// tienen su dato.
class CompareChartBuilder {
  const CompareChartBuilder();

  // Métricas en el orden en que se ofrecen, con su título.
  static final Map<CompareRowKind, String> _titles = {
    CompareRowKind.combinedConsumption: AppTexts.compareChartConsumption,
    CompareRowKind.co2: AppTexts.compareChartCo2,
    CompareRowKind.annualCost: AppTexts.compareChartAnnualCost,
    CompareRowKind.safety: AppTexts.compareChartSafety,
  };

  List<CompareChartMetricEntity> build(
    List<CompareTableSectionEntity> sections,
  ) {
    final rows = {
      for (final section in sections)
        for (final row in section.rows) row.kind: row,
    };
    return [
      for (final entry in _titles.entries)
        ?_metricOf(entry.key, entry.value, rows[entry.key]),
    ];
  }

  CompareChartMetricEntity? _metricOf(
    CompareRowKind kind,
    String title,
    CompareTableRowEntity? row,
  ) {
    if (row == null) return null;
    final bars = [
      for (final (index, cell) in row.cells.indexed)
        CompareChartBarEntity(
          slotIndex: index,
          value: cell?.value,
          valueText: _textOf(kind, cell),
          isBest: cell?.isBest ?? false,
        ),
    ];
    final withData = bars.where((bar) => bar.value != null).length;
    if (withData < CompareConfig.minSlots) return null;
    return CompareChartMetricEntity(kind: kind, label: title, bars: bars);
  }

  // Sin dato es "—"; el consumo lleva su unidad y el resto ya la trae.
  String _textOf(CompareRowKind kind, CompareTableCellEntity? cell) {
    if (cell == null || cell.value == null) return AppTexts.noDataLabel;
    return kind == CompareRowKind.combinedConsumption
        ? AppTexts.compareChartKmPerLiterValue(cell.text)
        : cell.text;
  }
}
