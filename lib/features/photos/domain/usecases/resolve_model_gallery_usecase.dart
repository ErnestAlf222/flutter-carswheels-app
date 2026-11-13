import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/datasources/gallery_cache_datasource.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/cached_gallery_entity.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/photo_entity.dart';
import 'package:cars_wheels_app/features/photos/domain/services/photo_key_builder.dart';
import 'package:cars_wheels_app/features/photos/domain/usecases/get_model_gallery_usecase.dart';

/// Devuelve la galería de un modelo usando la caché antes de ir a la red.
class ResolveModelGalleryUseCase {
  const ResolveModelGalleryUseCase({
    required this.cache,
    required this.getGallery,
    required this.keyBuilder,
    required this.clock,
  });

  final GalleryCacheDatasource cache;
  final GetModelGalleryUseCase getGallery;
  final PhotoKeyBuilder keyBuilder;

  /// Reloj inyectado para controlar el tiempo en las pruebas.
  final DateTime Function() clock;

  /// Con la red caída devuelve la galería vencida con fotos; si no, relanza.
  Future<List<PhotoEntity>> call({
    required String brand,
    required String modelName,
    required int year,
  }) async {
    final key = keyFor(brand: brand, modelName: modelName, year: year);
    final cached = await cache.read(key);
    if (cached != null && _isFresh(cached)) return cached.photos;
    try {
      final photos = await getGallery(
        brand: brand,
        modelName: modelName,
        year: year,
      );
      await cache.write(
        key,
        CachedGalleryEntity(photos: photos, savedAt: clock()),
      );
      return photos;
    } on AppFailure {
      if (cached != null && !cached.isMiss) return cached.photos;
      rethrow;
    }
  }

  /// Versión y etiqueta de galería, y la clave completa de la foto del modelo.
  String keyFor({
    required String brand,
    required String modelName,
    required int year,
  }) {
    final photoKey = keyBuilder.build(
      brand: brand,
      modelName: modelName,
      year: year,
    );
    return [
      PhotosConfig.galleryCacheKeyVersion,
      PhotosConfig.galleryCacheKeyTag,
      photoKey,
    ].join(PhotosConfig.cacheKeySeparator);
  }

  // Vigente mientras no cumpla los días de vigencia de su tipo.
  bool _isFresh(CachedGalleryEntity entry) {
    final days = entry.isMiss
        ? PhotosConfig.photoMissTimeToLiveDays
        : PhotosConfig.photoCacheTimeToLiveDays;
    return clock().difference(entry.savedAt) < Duration(days: days);
  }
}
