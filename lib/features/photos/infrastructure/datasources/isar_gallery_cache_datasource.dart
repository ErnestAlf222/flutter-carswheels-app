import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/features/photos/domain/domain.dart';
import 'package:cars_wheels_app/features/photos/infrastructure/mappers/cached_gallery_mapper.dart';
import 'package:cars_wheels_app/features/photos/infrastructure/models/photo_gallery_cache_model.dart';

/// Caché de galerías guardada en Isar.
class IsarGalleryCacheDatasource implements GalleryCacheDatasource {
  const IsarGalleryCacheDatasource(this.isar);

  final Isar isar;

  @override
  Future<CachedGalleryEntity?> read(String key) async {
    final model = await isar.photoGalleryCacheModels.getByKey(key);
    return model == null ? null : CachedGalleryMapper.toEntity(model);
  }

  @override
  Future<void> write(String key, CachedGalleryEntity entry) {
    final model = CachedGalleryMapper.toModel(key, entry);
    return isar.writeTxn(() => isar.photoGalleryCacheModels.putByKey(model));
  }
}
