import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/datasources/vehicle_detail_cache_datasource.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/cached_detail_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_detail_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/repositories/vehicle_specs_repository.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/services/vehicle_detail_key_builder.dart';

/// Devuelve el detalle de una versión usando la caché antes de ir a la red.
class ResolveVehicleDetailUseCase {
  const ResolveVehicleDetailUseCase({
    required this.cache,
    required this.repository,
    required this.keyBuilder,
    required this.clock,
  });

  final VehicleDetailCacheDatasource cache;
  final VehicleSpecsRepository repository;
  final VehicleDetailKeyBuilder keyBuilder;

  /// Reloj inyectado para controlar el tiempo en las pruebas.
  final DateTime Function() clock;

  /// Con la red caída devuelve el detalle vencido si existe; si no, relanza.
  Future<VehicleDetailEntity?> call({
    required int id,
    required int year,
    required String brand,
    required String model,
  }) async {
    final key = keyBuilder.build(id);
    final cached = await cache.read(key);
    if (cached != null && _isFresh(cached)) return cached.detail;
    try {
      final detail = await repository.getDetail(
        id,
        year: year,
        brand: brand,
        model: model,
      );
      // Sin registro no se guarda: se volverá a intentar después.
      if (detail == null) return null;
      await cache.write(
        key,
        CachedDetailEntity(detail: detail, savedAt: clock()),
      );
      return detail;
    } on AppFailure {
      if (cached != null) return cached.detail;
      rethrow;
    }
  }

  // Vigente mientras no cumpla los días de vigencia.
  bool _isFresh(CachedDetailEntity entry) {
    const lifetime = Duration(
      days: VehicleSpecsConfig.vehicleDetailCacheTimeToLiveDays,
    );
    return clock().difference(entry.savedAt) < lifetime;
  }
}
