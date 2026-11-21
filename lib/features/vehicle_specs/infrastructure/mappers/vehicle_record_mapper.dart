import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_record_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/models/fuel_economy_vehicle_model.dart';

/// Convierte el registro de la API en la entidad del dominio.
class VehicleRecordMapper {
  const VehicleRecordMapper._();

  static VehicleRecordEntity toEntity(FuelEconomyVehicleModel model) {
    return VehicleRecordEntity(
      vehicleClass: model.vehicleClass,
      atvType: model.atvType,
      combinedMpg:
          _positive(model.combinedMpgPrecise) ?? _positive(model.combinedMpg),
      cityMpg: _positive(model.cityMpg),
      highwayMpg: _positive(model.highwayMpg),
      annualFuelCostUsd: int.tryParse(model.annualFuelCost ?? ''),
      cylinders: int.tryParse(model.cylinders ?? ''),
      displacementLiters: double.tryParse(model.displacement ?? ''),
      transmission: model.transmission,
      drive: model.drive,
      fuelType: model.fuelType,
      make: model.make,
      model: model.model,
      year: int.tryParse(model.year ?? ''),
      electricRangeMiles: _positive(model.electricRange),
      totalRangeMiles: _positive(model.totalRange),
      electricConsumptionKwhPer100Miles: _positive(model.electricConsumption),
      co2GramsPerMile: _nonNegative(model.co2TailpipeGramsPerMile),
      fuelEconomyScore: int.tryParse(model.fuelEconomyScore ?? ''),
      greenhouseGasScore: int.tryParse(model.greenhouseGasScore ?? ''),
      hasTurbo: model.turbocharger == VehicleSpecsConfig.turbochargerMark,
      hasSupercharger:
          model.supercharger == VehicleSpecsConfig.superchargerMark,
      passengerVolumeCubicFeet: _volume([
        model.passengerVolume2Door,
        model.passengerVolume4Door,
        model.passengerVolumeHatchback,
      ]),
      cargoVolumeCubicFeet: _volume([
        model.cargoVolume2Door,
        model.cargoVolume4Door,
        model.cargoVolumeHatchback,
      ]),
      chargeHours240: _positive(model.charge240),
      chargeHours120: _positive(model.charge120),
      hasStartStop: _flag(model.startStop),
    );
  }

  // Suma de los volúmenes que aplican; nulo si ninguno es mayor que 0.
  static double? _volume(List<String?> texts) {
    final total = texts.fold<double>(
      0,
      (sum, text) => sum + (_positive(text) ?? 0),
    );
    return total > 0 ? total : null;
  }

  // 'Y' es verdadero, 'N' falso y cualquier otro valor es dato ausente.
  static bool? _flag(String? text) => switch (text) {
    VehicleSpecsConfig.startStopYes => true,
    VehicleSpecsConfig.startStopNo => false,
    _ => null,
  };

  // El número solo si es válido y no negativo; el 0 se conserva.
  static double? _nonNegative(String? text) {
    final value = double.tryParse(text ?? '');
    return value != null && value >= 0 ? value : null;
  }

  // El número solo si es válido y mayor que 0.
  static double? _positive(String? text) {
    final value = double.tryParse(text ?? '');
    return value != null && value > 0 ? value : null;
  }
}
