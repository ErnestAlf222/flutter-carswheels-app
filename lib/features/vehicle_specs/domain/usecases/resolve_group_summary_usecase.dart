import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/datasources/summary_cache_datasource.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/cached_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/group_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/services/summary_key_builder.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/usecases/get_group_summary_usecase.dart';

/// Devuelve el resumen de un grupo usando la caché antes de ir a la red.
class ResolveGroupSummaryUseCase {
  const ResolveGroupSummaryUseCase({
    required this.cache,
    required this.getGroupSummary,
    required this.keyBuilder,
    required this.clock,
  });

  final SummaryCacheDatasource cache;
  final GetGroupSummaryUseCase getGroupSummary;
  final SummaryKeyBuilder keyBuilder;

  /// Reloj inyectado para controlar el tiempo en las pruebas.
  final DateTime Function() clock;

  /// Con la red caída devuelve el resumen vencido si existe; si no, relanza.
  Future<GroupSummaryEntity?> call({
    required int year,
    required String brand,
    required String groupName,
    required List<String> variantNames,
  }) async {
    final key = [
      VehicleSpecsConfig.summaryCacheKeyVersion,
      keyBuilder.build(brand: brand, groupName: groupName, year: year),
    ].join(PhotosConfig.cacheKeySeparator);
    final cached = await cache.read(key);
    if (cached != null && _isFresh(cached)) return cached.summary;
    try {
      final summary = await getGroupSummary(
        year: year,
        brand: brand,
        variantNames: variantNames,
      );
      // Sin vehículo no se guarda: se volverá a intentar después.
      if (summary == null) return null;
      await cache.write(
        key,
        CachedSummaryEntity(summary: summary, savedAt: clock()),
      );
      return summary;
    } on AppFailure {
      if (cached != null) return cached.summary;
      rethrow;
    }
  }

  // Vigente mientras no cumpla los días de vigencia.
  bool _isFresh(CachedSummaryEntity entry) {
    const lifetime = Duration(
      days: VehicleSpecsConfig.summaryCacheTimeToLiveDays,
    );
    return clock().difference(entry.savedAt) < lifetime;
  }
}
