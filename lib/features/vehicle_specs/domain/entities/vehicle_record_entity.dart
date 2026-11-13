import 'package:equatable/equatable.dart';

/// Datos de un vehículo de FuelEconomy que usan el resumen y el detalle.
class VehicleRecordEntity extends Equatable {
  const VehicleRecordEntity({
    required this.vehicleClass,
    required this.atvType,
    required this.combinedMpg,
    this.cityMpg,
    this.highwayMpg,
    this.annualFuelCostUsd,
    this.cylinders,
    this.displacementLiters,
    this.transmission,
    this.drive,
    this.fuelType,
    this.make,
    this.model,
    this.year,
    this.electricRangeMiles,
    this.totalRangeMiles,
    this.electricConsumptionKwhPer100Miles,
    this.co2GramsPerMile,
    this.fuelEconomyScore,
    this.greenhouseGasScore,
  });

  /// Clase del vehículo en inglés, como la entrega la API.
  final String? vehicleClass;

  /// Tipo de combustible o motorización; vacío en gasolina normal.
  final String atvType;

  /// Millas por galón combinadas; nulo si la API no las trae o son 0.
  final double? combinedMpg;

  /// Millas por galón en ciudad y en carretera; nulas si faltan o son 0.
  final double? cityMpg;
  final double? highwayMpg;

  /// Costo anual de combustible en dólares.
  final int? annualFuelCostUsd;
  final int? cylinders;
  final double? displacementLiters;
  final String? transmission;
  final String? drive;
  final String? fuelType;
  final String? make;
  final String? model;
  final int? year;

  /// Autonomía eléctrica de un enchufable y autonomía total, en millas.
  final double? electricRangeMiles;
  final double? totalRangeMiles;

  /// Consumo eléctrico en kWh por 100 millas.
  final double? electricConsumptionKwhPer100Miles;

  /// CO₂ del escape en gramos por milla; 0 es válido en un eléctrico.
  final double? co2GramsPerMile;

  /// Puntuaciones EPA; -1 significa sin dato.
  final int? fuelEconomyScore;
  final int? greenhouseGasScore;

  @override
  List<Object?> get props => [
    vehicleClass,
    atvType,
    combinedMpg,
    cityMpg,
    highwayMpg,
    annualFuelCostUsd,
    cylinders,
    displacementLiters,
    transmission,
    drive,
    fuelType,
    make,
    model,
    year,
    electricRangeMiles,
    totalRangeMiles,
    electricConsumptionKwhPer100Miles,
    co2GramsPerMile,
    fuelEconomyScore,
    greenhouseGasScore,
  ];
}
