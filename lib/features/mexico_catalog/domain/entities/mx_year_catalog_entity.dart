import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_vehicle_entity.dart';

/// Todas las filas limpias de un año, con las cuentas de la limpieza.
class MxYearCatalogEntity extends Equatable {
  const MxYearCatalogEntity({
    required this.year,
    required this.vehicles,
    required this.rawRowCount,
    required this.droppedKmPerLiterCount,
  });

  final int year;

  /// Filas ya sin duplicados idénticos.
  final List<MxVehicleEntity> vehicles;

  /// Filas que devolvió el datastore antes de colapsar.
  final int rawRowCount;

  /// Filas a las que se les descartó algún km/l por no ser plausible.
  final int droppedKmPerLiterCount;

  @override
  List<Object?> get props => [
    year,
    vehicles,
    rawRowCount,
    droppedKmPerLiterCount,
  ];
}
