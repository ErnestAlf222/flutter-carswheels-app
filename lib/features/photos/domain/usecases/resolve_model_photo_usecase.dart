import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/datasources/photo_cache_datasource.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/cached_photo_entity.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/photo_entity.dart';
import 'package:cars_wheels_app/features/photos/domain/services/photo_key_builder.dart';
import 'package:cars_wheels_app/features/photos/domain/usecases/get_model_photo_usecase.dart';

/// Devuelve la foto de un modelo usando la caché antes de ir a la red.
class ResolveModelPhotoUseCase {
  const ResolveModelPhotoUseCase({
    required this.cache,
    required this.getModelPhoto,
    required this.keyBuilder,
    required this.clock,
  });

  final PhotoCacheDatasource cache;
  final GetModelPhotoUseCase getModelPhoto;
  final PhotoKeyBuilder keyBuilder;

  /// Reloj inyectado para controlar el tiempo en las pruebas.
  final DateTime Function() clock;

  /// Con la red caída devuelve la foto vencida si existe; si no, relanza.
  Future<PhotoEntity?> call({
    required String brand,
    required String modelName,
    required int year,
  }) async {
    final key = keyBuilder.build(
      brand: brand,
      modelName: modelName,
      year: year,
    );
    final cached = await cache.read(key);
    if (cached != null && _isFresh(cached)) return cached.photo;
    try {
      final photo = await getModelPhoto(
        brand: brand,
        modelName: modelName,
        year: year,
      );
      await cache.write(key, CachedPhotoEntity(photo: photo, savedAt: clock()));
      return photo;
    } on AppFailure {
      if (cached != null && !cached.isMiss) return cached.photo;
      rethrow;
    }
  }

  // Vigente mientras no cumpla los días de vigencia de su tipo.
  bool _isFresh(CachedPhotoEntity entry) {
    final days = entry.isMiss
        ? PhotosConfig.photoMissTimeToLiveDays
        : PhotosConfig.photoCacheTimeToLiveDays;
    return clock().difference(entry.savedAt) < Duration(days: days);
  }
}
