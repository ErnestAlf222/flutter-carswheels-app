import 'package:cars_wheels_app/core/core.dart';

/// Registro de un vehículo de FuelEconomy con los campos en texto.
class FuelEconomyVehicleModel {
  const FuelEconomyVehicleModel({
    required this.vehicleClass,
    required this.atvType,
    required this.combinedMpg,
    required this.combinedMpgPrecise,
    this.cityMpg,
    this.highwayMpg,
    this.annualFuelCost,
    this.cylinders,
    this.displacement,
    this.transmission,
    this.drive,
    this.fuelType,
    this.make,
    this.model,
    this.year,
    this.electricRange,
    this.totalRange,
    this.electricConsumption,
    this.co2TailpipeGramsPerMile,
    this.fuelEconomyScore,
    this.greenhouseGasScore,
  });

  /// Tolera campos ausentes o vacíos; falla si la raíz no es un objeto.
  factory FuelEconomyVehicleModel.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const ParsingFailure('El registro del vehículo no es un objeto');
    }
    return FuelEconomyVehicleModel(
      vehicleClass: _readText(json[VehicleSpecsConfig.vehicleClassKey]),
      atvType: _readText(json[VehicleSpecsConfig.atvTypeKey]) ?? '',
      combinedMpg: _readText(json[VehicleSpecsConfig.combinedMpgKey]),
      combinedMpgPrecise: _readText(
        json[VehicleSpecsConfig.combinedMpgPreciseKey],
      ),
      cityMpg: _readText(json[VehicleSpecsConfig.cityMpgKey]),
      highwayMpg: _readText(json[VehicleSpecsConfig.highwayMpgKey]),
      annualFuelCost: _readText(json[VehicleSpecsConfig.annualFuelCostKey]),
      cylinders: _readText(json[VehicleSpecsConfig.cylindersKey]),
      displacement: _readText(json[VehicleSpecsConfig.displacementKey]),
      transmission: _readText(json[VehicleSpecsConfig.transmissionKey]),
      drive: _readText(json[VehicleSpecsConfig.driveKey]),
      fuelType: _readText(json[VehicleSpecsConfig.fuelTypeKey]),
      make: _readText(json[VehicleSpecsConfig.makeKey]),
      model: _readText(json[VehicleSpecsConfig.modelKey]),
      year: _readText(json[VehicleSpecsConfig.yearKey]),
      electricRange: _readText(json[VehicleSpecsConfig.electricRangeKey]),
      totalRange: _readText(json[VehicleSpecsConfig.totalRangeKey]),
      electricConsumption: _readText(
        json[VehicleSpecsConfig.electricConsumptionKey],
      ),
      co2TailpipeGramsPerMile: _readText(
        json[VehicleSpecsConfig.co2TailpipeKey],
      ),
      fuelEconomyScore: _readText(json[VehicleSpecsConfig.fuelEconomyScoreKey]),
      greenhouseGasScore: _readText(
        json[VehicleSpecsConfig.greenhouseGasScoreKey],
      ),
    );
  }

  final String? vehicleClass;
  final String atvType;
  final String? combinedMpg;
  final String? combinedMpgPrecise;
  final String? cityMpg;
  final String? highwayMpg;
  final String? annualFuelCost;
  final String? cylinders;
  final String? displacement;
  final String? transmission;
  final String? drive;
  final String? fuelType;
  final String? make;
  final String? model;
  final String? year;
  final String? electricRange;
  final String? totalRange;
  final String? electricConsumption;
  final String? co2TailpipeGramsPerMile;
  final String? fuelEconomyScore;
  final String? greenhouseGasScore;

  // Texto sin espacios sobrantes; nulo si falta o queda vacío.
  static String? _readText(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
