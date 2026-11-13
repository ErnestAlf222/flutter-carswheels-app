import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/powertrain.dart';

/// Ficha de una versión concreta de un modelo.
class VehicleDetailEntity extends Equatable {
  const VehicleDetailEntity({
    required this.id,
    required this.year,
    required this.make,
    required this.model,
    required this.vehicleClass,
    required this.powertrain,
    required this.transmission,
    required this.cylinders,
    required this.displacementLiters,
    required this.drive,
    required this.fuelType,
    required this.cityKmPerLiter,
    required this.highwayKmPerLiter,
    required this.combinedKmPerLiter,
    required this.annualFuelCostUsd,
    this.co2GramsPerKilometer,
    this.electricRangeKilometers,
    this.totalRangeKilometers,
    this.electricConsumptionKwhPer100Kilometers,
    this.hybridGasKmPerLiter,
    this.fuelScore,
    this.emissionsScore,
  });

  final int id;

  /// Año, marca y modelo de la opción pedida.
  final int year;
  final String make;
  final String model;

  /// Clase original en inglés; la traducción se hace al mostrarla.
  final String? vehicleClass;
  final Powertrain powertrain;
  final String? transmission;
  final int? cylinders;
  final double? displacementLiters;
  final String? drive;
  final String? fuelType;

  /// Consumos en km/l; solo con motorización de combustión.
  final double? cityKmPerLiter;
  final double? highwayKmPerLiter;
  final double? combinedKmPerLiter;
  final int? annualFuelCostUsd;

  /// CO₂ en g/km; 0 se conserva en eléctricos.
  final double? co2GramsPerKilometer;

  /// Autonomía eléctrica (solo enchufables) y total (eléctricos e hidrógeno).
  final double? electricRangeKilometers;
  final double? totalRangeKilometers;

  /// Consumo eléctrico en kWh por 100 km (eléctricos y enchufables).
  final double? electricConsumptionKwhPer100Kilometers;

  /// Consumo con gasolina en modo híbrido, solo enchufables.
  final double? hybridGasKmPerLiter;

  /// Puntuaciones de 1 a 10; nulas si no hay dato válido.
  final int? fuelScore;
  final int? emissionsScore;

  @override
  List<Object?> get props => [
    id,
    year,
    make,
    model,
    vehicleClass,
    powertrain,
    transmission,
    cylinders,
    displacementLiters,
    drive,
    fuelType,
    cityKmPerLiter,
    highwayKmPerLiter,
    combinedKmPerLiter,
    annualFuelCostUsd,
    co2GramsPerKilometer,
    electricRangeKilometers,
    totalRangeKilometers,
    electricConsumptionKwhPer100Kilometers,
    hybridGasKmPerLiter,
    fuelScore,
    emissionsScore,
  ];
}
