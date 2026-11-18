import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Fila limpia del catálogo de CONUEE; el dato ausente es nulo.
class MxVehicleEntity extends Equatable {
  const MxVehicleEntity({
    required this.id,
    required this.brand,
    required this.rawModel,
    required this.model,
    this.engineKind,
    this.fuelType,
    this.cityKmPerLiter,
    this.highwayKmPerLiter,
    this.combinedKmPerLiter,
    this.cityCo2GramsPerKilometer,
    this.highwayCo2GramsPerKilometer,
    this.combinedCo2GramsPerKilometer,
    this.cylinders,
    this.displacementCubicCentimeters,
    this.transmission,
    this.power,
    this.torque,
  });

  /// Posición de la fila dentro del año ya sin duplicados.
  final int id;
  final String brand;

  /// Nombre tal como viene de CONUEE.
  final String rawModel;

  /// Nombre sin cilindrada, potencia, transmisión ni electrificación.
  final String model;

  /// Nulo si el combustible no está en la tabla.
  final EngineKind? engineKind;

  /// Combustible tal como viene de CONUEE.
  final String? fuelType;

  /// Consumos en km/l; nulos en eléctricos, enchufables y valores no plausibles.
  final double? cityKmPerLiter;
  final double? highwayKmPerLiter;
  final double? combinedKmPerLiter;
  final double? cityCo2GramsPerKilometer;
  final double? highwayCo2GramsPerKilometer;
  final double? combinedCo2GramsPerKilometer;

  /// Etiqueta canónica; un valor no observado se conserva tal cual.
  final String? cylinders;
  final int? displacementCubicCentimeters;
  final String? transmission;

  /// Texto limpio como "190 @ 6000"; nulo si el patrón no es inequívoco.
  final String? power;
  final String? torque;

  @override
  List<Object?> get props => [
    id,
    brand,
    rawModel,
    model,
    engineKind,
    fuelType,
    cityKmPerLiter,
    highwayKmPerLiter,
    combinedKmPerLiter,
    cityCo2GramsPerKilometer,
    highwayCo2GramsPerKilometer,
    combinedCo2GramsPerKilometer,
    cylinders,
    displacementCubicCentimeters,
    transmission,
    power,
    torque,
  ];
}
