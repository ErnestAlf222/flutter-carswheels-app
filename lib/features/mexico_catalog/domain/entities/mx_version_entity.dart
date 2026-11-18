import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_vehicle_entity.dart';

/// Versión de un grupo: una fila del catálogo con su nombre original.
class MxVersionEntity extends Equatable {
  const MxVersionEntity({required this.label, required this.vehicle});

  /// Nombre original de CONUEE sin el prefijo de la marca.
  final String label;
  final MxVehicleEntity vehicle;

  @override
  List<Object?> get props => [label, vehicle];
}
