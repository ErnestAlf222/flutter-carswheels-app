import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/powertrain.dart';

/// Resumen de un modelo: clase, motorización y consumo combinado.
class ModelSummaryEntity extends Equatable {
  const ModelSummaryEntity({
    required this.vehicleClass,
    required this.powertrain,
    required this.combinedKmPerLiter,
  });

  /// Clase original en inglés; la traducción se hace al mostrarla.
  final String? vehicleClass;
  final Powertrain powertrain;

  /// Solo para combustión; nulo en eléctricos, enchufables y otros.
  final double? combinedKmPerLiter;

  @override
  List<Object?> get props => [vehicleClass, powertrain, combinedKmPerLiter];
}
