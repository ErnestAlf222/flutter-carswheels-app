import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Una versión de un grupo: su detalle y la variante a la que pertenece.
class GroupVersionEntity extends Equatable {
  const GroupVersionEntity({
    required this.variantName,
    required this.detail,
    this.label,
  });

  final String variantName;
  final VehicleDetailEntity detail;

  /// Nombre ya listo para mostrar (México); sin él se arma con el descriptor.
  final String? label;

  @override
  List<Object?> get props => [variantName, detail, label];
}
