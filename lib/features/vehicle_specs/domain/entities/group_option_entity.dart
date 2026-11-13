import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_option_entity.dart';

/// Una opción de un grupo con el nombre de la variante a la que pertenece.
class GroupOptionEntity extends Equatable {
  const GroupOptionEntity({required this.variantName, required this.option});

  final String variantName;
  final VehicleOptionEntity option;

  @override
  List<Object?> get props => [variantName, option];
}
