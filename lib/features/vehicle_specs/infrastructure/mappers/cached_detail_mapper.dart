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
      savedAtMillis: entity.savedAt.millisecondsSinceEpoch,
    );
  }
}
