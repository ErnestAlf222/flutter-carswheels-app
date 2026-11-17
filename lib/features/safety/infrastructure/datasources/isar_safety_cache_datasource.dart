import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/features/safety/domain/datasources/safety_cache_datasource.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/cached_group_safety_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/cached_recalls_entity.dart';
import 'package:cars_wheels_app/features/safety/infrastructure/mappers/cached_group_safety_mapper.dart';
import 'package:cars_wheels_app/features/safety/infrastructure/mappers/cached_recalls_mapper.dart';
import 'package:cars_wheels_app/features/safety/infrastructure/models/recalls_cache_model.dart';
import 'package:cars_wheels_app/features/safety/infrastructure/models/safety_no_match_cache_model.dart';
import 'package:cars_wheels_app/features/safety/infrastructure/models/safety_ratings_cache_model.dart';

/// Cachés de seguridad guardadas en Isar.
class IsarSafetyCacheDatasource implements SafetyCacheDatasource {
  const IsarSafetyCacheDatasource(this.isar);

  final Isar isar;

  @override
  Future<CachedGroupSafetyEntity?> readRatings(String key) async {
    final model = await isar.safetyRatingsCacheModels.getByKey(key);
    return model == null ? null : CachedGroupSafetyMapper.toEntity(model);
  }

  @override
  Future<void> writeRatings(String key, CachedGroupSafetyEntity entry) {
    final model = CachedGroupSafetyMapper.toModel(key, entry);
    return isar.writeTxn(() => isar.safetyRatingsCacheModels.putByKey(model));
  }

  @override
  Future<CachedRecallsEntity?> readRecalls(String key) async {
    final model = await isar.recallsCacheModels.getByKey(key);
    return model == null ? null : CachedRecallsMapper.toEntity(model);
  }

  @override
  Future<void> writeRecalls(String key, CachedRecallsEntity entry) {
    final model = CachedRecallsMapper.toModel(key, entry);
    return isar.writeTxn(() => isar.recallsCacheModels.putByKey(model));
  }

  @override
  Future<DateTime?> readNoMatch(String key) async {
    final model = await isar.safetyNoMatchCacheModels.getByKey(key);
    return model == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(model.savedAtMillis);
  }

  @override
  Future<void> writeNoMatch(String key, DateTime savedAt) {
    final model = SafetyNoMatchCacheModel(
      key: key,
      savedAtMillis: savedAt.millisecondsSinceEpoch,
    );
    return isar.writeTxn(() => isar.safetyNoMatchCacheModels.putByKey(model));
  }
}
