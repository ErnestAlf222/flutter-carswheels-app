import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/l10n/l10n.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_engine_kind.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_table_cell_entity.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_table_row_entity.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_table_section_entity.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_vehicle_detail_entity.dart';

// Criterio para resaltar el mejor valor de una fila.
enum _Best { none, higher, lower }

// Mercados donde una fila tiene sentido.
enum _Scope { both, unitedStatesOnly, mexicoOnly }

// Definición de una fila: de dónde sale el valor y cómo se compara.
class _RowSpec {
  const _RowSpec.number({
    required this.kind,
    required this.label,
    required this.number,
    required this.format,
    required this.best,
    this.digits = 0,
    this.scope = _Scope.both,
  }) : text = null;

  const _RowSpec.text({
    required this.kind,
    required this.label,
    required this.text,
    this.scope = _Scope.both,
  }) : number = null,
       format = null,
       best = _Best.none,
       digits = 0;

  final CompareRowKind kind;
  final String label;
  final double? Function(CompareVehicleDetailEntity)? number;
  final String Function(double)? format;
  final String? Function(CompareVehicleDetailEntity)? text;
  final _Best best;

  // Decimales con que se muestra la cifra; con ellos se decide quién gana.
  final int digits;
  final _Scope scope;
}

// Un grupo de filas con su título.
class _SectionSpec {
  const _SectionSpec(this.title, this.rows);

  final String title;
  final List<_RowSpec> rows;
}

/// Arma las filas visibles de la tabla comparativa y marca el mejor valor.
///
/// Una fila solo aparece si algún vehículo cargado tiene el dato; si falta en
/// uno, su celda es "—". El mejor valor se marca solo donde hay un criterio
/// claro, con al menos dos datos y sin que todos sean iguales.
class CompareTableBuilder {
  const CompareTableBuilder();

  static final List<_SectionSpec> _sections = [
    _SectionSpec(AppTexts.compareSectionConsumption, [
      _RowSpec.number(
        kind: CompareRowKind.combinedConsumption,
        label: AppTexts.compareRowCombinedConsumption,
        number: (detail) => detail.combinedKmPerLiter,
        format: AppTexts.kmPerLiterFigure,
        best: _Best.higher,
        digits: TextConfig.kmPerLiterFractionDigits,
      ),
      _RowSpec.number(
        kind: CompareRowKind.cityConsumption,
        label: AppTexts.compareRowCityConsumption,
        number: (detail) => detail.cityKmPerLiter,
        format: AppTexts.kmPerLiterFigure,
        best: _Best.higher,
        digits: TextConfig.kmPerLiterFractionDigits,
      ),
      _RowSpec.number(
        kind: CompareRowKind.highwayConsumption,
        label: AppTexts.compareRowHighwayConsumption,
        number: (detail) => detail.highwayKmPerLiter,
        format: AppTexts.kmPerLiterFigure,
        best: _Best.higher,
        digits: TextConfig.kmPerLiterFractionDigits,
      ),
      _RowSpec.number(
        kind: CompareRowKind.co2,
        label: AppTexts.co2Label,
        number: (detail) => detail.co2GramsPerKilometer,
        format: AppTexts.gramsPerKilometerFigure,
        best: _Best.lower,
      ),
    ]),
    _SectionSpec(AppTexts.compareSectionEngine, [
      _RowSpec.text(
        kind: CompareRowKind.engine,
        label: AppTexts.compareRowEngine,
        text: (detail) => _engineLabel(detail.engineKind),
      ),
      _RowSpec.text(
        kind: CompareRowKind.fuel,
        label: AppTexts.detailFuelRowLabel,
        text: (detail) => detail.fuelLabel,
      ),
      _RowSpec.text(
        kind: CompareRowKind.cylinders,
        label: AppTexts.detailCylindersRowLabel,
        text: (detail) => detail.cylindersLabel,
      ),
      _RowSpec.text(
        kind: CompareRowKind.transmission,
        label: AppTexts.detailTransmissionRowLabel,
        text: (detail) => detail.transmissionLabel,
      ),
      _RowSpec.text(
        kind: CompareRowKind.drive,
        label: AppTexts.detailDriveRowLabel,
        text: (detail) => detail.driveLabel,
        scope: _Scope.unitedStatesOnly,
      ),
      _RowSpec.text(
        kind: CompareRowKind.vehicleClass,
        label: AppTexts.detailClassRowLabel,
        text: (detail) => detail.classLabel,
        scope: _Scope.unitedStatesOnly,
      ),
      _RowSpec.text(
        kind: CompareRowKind.power,
        label: AppTexts.detailPowerRowLabel,
        text: (detail) => detail.powerLabel,
        scope: _Scope.mexicoOnly,
      ),
      _RowSpec.text(
        kind: CompareRowKind.torque,
        label: AppTexts.detailTorqueRowLabel,
        text: (detail) => detail.torqueLabel,
        scope: _Scope.mexicoOnly,
      ),
      _RowSpec.text(
        kind: CompareRowKind.compression,
        label: AppTexts.detailCompressionRowLabel,
        text: (detail) => detail.compressionLabel,
        scope: _Scope.mexicoOnly,
      ),
    ]),
    _SectionSpec(AppTexts.compareSectionSafetyCost, [
      _RowSpec.number(
        kind: CompareRowKind.annualCost,
        label: AppTexts.compareRowAnnualCost,
        number: (detail) => detail.annualFuelCostUsd?.toDouble(),
        format: (value) => AppTexts.annualCostLabel(value.round()),
        best: _Best.lower,
        scope: _Scope.unitedStatesOnly,
      ),
      _RowSpec.number(
        kind: CompareRowKind.safety,
        label: AppTexts.compareRowSafety,
        number: (detail) => detail.safetyStars?.toDouble(),
        format: (value) => AppTexts.compareStarsValue(value.round()),
        best: _Best.higher,
        scope: _Scope.unitedStatesOnly,
      ),
    ]),
  ];

  /// [columns] lleva un dato por vehículo en el orden de la selección; un nulo
  /// es una columna que aún carga o falló y no entra a ningún cálculo.
  List<CompareTableSectionEntity> build({
    required String marketCode,
    required List<CompareVehicleDetailEntity?> columns,
  }) {
    final isMexico = marketCode == MarketConfig.mexicoCode;
    return [
      for (final section in _sections)
        if (_rowsOf(section, columns, isMexico) case final rows
            when rows.isNotEmpty)
          CompareTableSectionEntity(title: section.title, rows: rows),
    ];
  }

  List<CompareTableRowEntity> _rowsOf(
    _SectionSpec section,
    List<CompareVehicleDetailEntity?> columns,
    bool isMexico,
  ) => [
    for (final spec in section.rows)
      if (_applies(spec.scope, isMexico)) ?_rowOf(spec, columns),
  ];

  bool _applies(_Scope scope, bool isMexico) => switch (scope) {
    _Scope.both => true,
    _Scope.unitedStatesOnly => !isMexico,
    _Scope.mexicoOnly => isMexico,
  };

  // Nula si ningún vehículo cargado tiene el dato.
  CompareTableRowEntity? _rowOf(
    _RowSpec spec,
    List<CompareVehicleDetailEntity?> columns,
  ) {
    final numbers = [
      for (final column in columns)
        if (column == null || spec.number == null)
          null
        else
          spec.number!(column),
    ];
    final texts = [
      for (final column in columns)
        if (column == null || spec.text == null) null else spec.text!(column),
    ];
    final hasData = spec.number != null
        ? numbers.any((value) => value != null)
        : texts.any((value) => value != null);
    if (!hasData) return null;
    final bestFlags = _bestFlags(spec, numbers);
    return CompareTableRowEntity(
      kind: spec.kind,
      label: spec.label,
      cells: [
        for (final (index, column) in columns.indexed)
          if (column == null)
            null
          else
            CompareTableCellEntity(
              text: _textOf(spec, numbers[index], texts[index]),
              value: numbers[index],
              isBest: bestFlags[index],
            ),
      ],
    );
  }

  String _textOf(_RowSpec spec, double? number, String? text) {
    if (spec.number != null) {
      return number == null ? AppTexts.noDataLabel : spec.format!(number);
    }
    return text ?? AppTexts.noDataLabel;
  }

  // Una marca por columna; se compara con la cifra tal como se muestra.
  List<bool> _bestFlags(_RowSpec spec, List<double?> numbers) {
    final none = [for (final _ in numbers) false];
    if (spec.best == _Best.none) return none;
    final shown = [
      for (final value in numbers)
        value == null ? null : double.parse(value.toStringAsFixed(spec.digits)),
    ];
    final present = shown.whereType<double>().toList();
    if (present.length < 2 || present.toSet().length == 1) return none;
    final target = spec.best == _Best.higher
        ? present.reduce((a, b) => a > b ? a : b)
        : present.reduce((a, b) => a < b ? a : b);
    return [for (final value in shown) value != null && value == target];
  }

  static String? _engineLabel(CompareEngineKind? kind) => switch (kind) {
    null => null,
    CompareEngineKind.electric => AppTexts.electricLabel,
    CompareEngineKind.hybrid => AppTexts.hybridLabel,
    CompareEngineKind.pluginHybrid => AppTexts.pluginHybridLabel,
    CompareEngineKind.hydrogen => AppTexts.hydrogenLabel,
    CompareEngineKind.combustion => AppTexts.compareEngineCombustionLabel,
  };
}
