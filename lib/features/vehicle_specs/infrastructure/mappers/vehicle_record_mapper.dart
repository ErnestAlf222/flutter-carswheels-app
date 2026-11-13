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
    );
  }

  // El número solo si es válido y mayor que 0.
  static double? _positive(String? text) {
    final value = double.tryParse(text ?? '');
    return value != null && value > 0 ? value : null;
  }
}
