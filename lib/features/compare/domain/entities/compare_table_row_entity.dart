import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/compare/domain/entities/compare_table_cell_entity.dart';

/// Qué dato muestra una fila de la tabla.
enum CompareRowKind {
  combinedConsumption,
  cityConsumption,
  highwayConsumption,
  co2,
  engine,
  fuel,
  cylinders,
  transmission,
  drive,
  vehicleClass,
  power,
  torque,
  compression,
  annualCost,
  safety,
}

/// Una fila: su etiqueta y un valor por columna.
class CompareTableRowEntity extends Equatable {
  const CompareTableRowEntity({
    required this.kind,
    required this.label,
    required this.cells,
  });

  final CompareRowKind kind;
  final String label;

  /// Una celda por vehículo, en el orden de la selección; nula si esa columna
  /// aún carga o falló.
  final List<CompareTableCellEntity?> cells;

  @override
  List<Object?> get props => [kind, label, cells];
}
