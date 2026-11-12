import 'package:cars_wheels_app/features/photos/domain/entities/cached_photo_entity.dart';

/// Fuente de datos de la caché de fotos.
abstract class PhotoCacheDatasource {
  Future<CachedPhotoEntity?> read(String key);

  /// Reemplaza la entrada si la clave ya existe.
  Future<void> write(String key, CachedPhotoEntity entry);
}
