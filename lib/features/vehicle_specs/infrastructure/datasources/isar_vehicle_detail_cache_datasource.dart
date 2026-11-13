import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/features/vehicle_specs/domain/datasources/vehicle_detail_cache_datasource.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/cached_detail_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/mappers/cached_detail_mapper.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/models/vehicle_detail_cache_model.dart';

/// Caché de detalles de versión guardada en Isar.
class IsarVehicleDetailCacheDatasource implements VehicleDetailCacheDatasource {
  const IsarVehicleDetailCacheDatasource(this.isar);

  final Isar isar;

  @override
  Future<CachedDetailEntity?> read(String key) async {
    final model = await isar.vehicleDetailCacheModels.getByKey(key);
    return model == null ? null : CachedDetailMapper.toEntity(model);
  }

  @override
  Future<void> write(String key, CachedDetailEntity entry) {
    final model = CachedDetailMapper.toModel(key, entry);
    return isar.writeTxn(() => isar.vehicleDetailCacheModels.putByKey(model));
  }
}
