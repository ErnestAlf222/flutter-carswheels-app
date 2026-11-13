import 'package:isar_community/isar.dart';

part 'vehicle_detail_cache_model.g.dart';

/// Entrada de la caché de detalles de versión guardada en Isar.
@collection
class VehicleDetailCacheModel {
  VehicleDetailCacheModel({
    required this.key,
    required this.vehicleId,
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
    required this.savedAtMillis,
    this.co2GramsPerKilometer,
    this.electricRangeKilometers,
    this.totalRangeKilometers,
    this.electricConsumptionKwhPer100Kilometers,
    this.hybridGasKmPerLiter,
    this.fuelScore,
    this.emissionsScore,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única: escribir una clave existente reemplaza la entrada.
  @Index(unique: true, replace: true)
  final String key;

  final int vehicleId;
  final int year;
  final String make;
  final String model;
  final String? vehicleClass;

  /// Nombre del valor del enum Powertrain.
  final String powertrain;
  final String? transmission;
  final int? cylinders;
  final double? displacementLiters;
  final String? drive;
  final String? fuelType;
  final double? cityKmPerLiter;
  final double? highwayKmPerLiter;
  final double? combinedKmPerLiter;
  final int? annualFuelCostUsd;
  final int savedAtMillis;
  final double? co2GramsPerKilometer;
  final double? electricRangeKilometers;
  final double? totalRangeKilometers;
  final double? electricConsumptionKwhPer100Kilometers;
  final double? hybridGasKmPerLiter;
  final int? fuelScore;
  final int? emissionsScore;
}
