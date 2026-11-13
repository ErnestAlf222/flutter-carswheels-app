import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/cached_detail_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/powertrain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_detail_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/models/vehicle_detail_cache_model.dart';

/// Convierte entre la entrada guardada en Isar y la entidad de caché.
class CachedDetailMapper {
  const CachedDetailMapper._();

  static CachedDetailEntity toEntity(VehicleDetailCacheModel model) {
    return CachedDetailEntity(
      detail: VehicleDetailEntity(
        id: model.vehicleId,
        year: model.year,
        make: model.make,
        model: model.model,
        vehicleClass: model.vehicleClass,
        powertrain: Powertrain.values.firstWhere(
          (powertrain) => powertrain.name == model.powertrain,
          orElse: () => Powertrain.other,
        ),
        transmission: model.transmission,
        cylinders: model.cylinders,
        displacementLiters: model.displacementLiters,
        drive: model.drive,
        fuelType: model.fuelType,
        cityKmPerLiter: model.cityKmPerLiter,
        highwayKmPerLiter: model.highwayKmPerLiter,
        combinedKmPerLiter: model.combinedKmPerLiter,
        annualFuelCostUsd: model.annualFuelCostUsd,
        co2GramsPerKilometer: model.co2GramsPerKilometer,
        electricRangeKilometers: model.electricRangeKilometers,
        totalRangeKilometers: model.totalRangeKilometers,
        electricConsumptionKwhPer100Kilometers:
            model.electricConsumptionKwhPer100Kilometers,
        hybridGasKmPerLiter: model.hybridGasKmPerLiter,
        fuelScore: model.fuelScore,
        emissionsScore: model.emissionsScore,
      ),
      savedAt: DateTime.fromMillisecondsSinceEpoch(model.savedAtMillis),
    );
  }

  static VehicleDetailCacheModel toModel(
    String key,
    CachedDetailEntity entity,
  ) {
    final detail = entity.detail;
    return VehicleDetailCacheModel(
      key: key,
      vehicleId: detail.id,
      year: detail.year,
      make: detail.make,
      model: detail.model,
      vehicleClass: detail.vehicleClass,
      powertrain: detail.powertrain.name,
      transmission: detail.transmission,
      cylinders: detail.cylinders,
      displacementLiters: detail.displacementLiters,
      drive: detail.drive,
      fuelType: detail.fuelType,
      cityKmPerLiter: detail.cityKmPerLiter,
      highwayKmPerLiter: detail.highwayKmPerLiter,
      combinedKmPerLiter: detail.combinedKmPerLiter,
      annualFuelCostUsd: detail.annualFuelCostUsd,
      co2GramsPerKilometer: detail.co2GramsPerKilometer,
      electricRangeKilometers: detail.electricRangeKilometers,
      totalRangeKilometers: detail.totalRangeKilometers,
      electricConsumptionKwhPer100Kilometers:
          detail.electricConsumptionKwhPer100Kilometers,
      hybridGasKmPerLiter: detail.hybridGasKmPerLiter,
      fuelScore: detail.fuelScore,
      emissionsScore: detail.emissionsScore,
      savedAtMillis: entity.savedAt.millisecondsSinceEpoch,
    );
  }
}
