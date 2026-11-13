import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/features/vehicle_specs/domain/datasources/summary_cache_datasource.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/cached_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/mappers/cached_summary_mapper.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/models/group_summary_cache_model.dart';

/// Caché de resúmenes guardada en Isar.
class IsarSummaryCacheDatasource implements SummaryCacheDatasource {
  const IsarSummaryCacheDatasource(this.isar);

  final Isar isar;

  @override
  Future<CachedSummaryEntity?> read(String key) async {
    final model = await isar.groupSummaryCacheModels.getByKey(key);
    return model == null ? null : CachedSummaryMapper.toEntity(model);
  }

  @override
  Future<void> write(String key, CachedSummaryEntity entry) {
    final model = CachedSummaryMapper.toModel(key, entry);
    return isar.writeTxn(() => isar.groupSummaryCacheModels.putByKey(model));
  }
}
