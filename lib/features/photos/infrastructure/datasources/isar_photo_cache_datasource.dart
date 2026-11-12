import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/features/photos/domain/datasources/photo_cache_datasource.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/cached_photo_entity.dart';
import 'package:cars_wheels_app/features/photos/infrastructure/mappers/cached_photo_mapper.dart';
import 'package:cars_wheels_app/features/photos/infrastructure/models/cached_photo_model.dart';

/// Caché de fotos guardada en Isar.
class IsarPhotoCacheDatasource implements PhotoCacheDatasource {
  const IsarPhotoCacheDatasource(this.isar);

  final Isar isar;

  @override
  Future<CachedPhotoEntity?> read(String key) async {
    final model = await isar.cachedPhotoModels.getByKey(key);
    return model == null ? null : CachedPhotoMapper.toEntity(model);
  }

  @override
  Future<void> write(String key, CachedPhotoEntity entry) {
    final model = CachedPhotoMapper.toModel(key, entry);
    return isar.writeTxn(() => isar.cachedPhotoModels.putByKey(model));
  }
}
