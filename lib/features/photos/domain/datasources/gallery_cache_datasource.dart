import 'package:cars_wheels_app/features/photos/domain/entities/cached_gallery_entity.dart';

/// Fuente de datos de la caché de galerías.
abstract class GalleryCacheDatasource {
  Future<CachedGalleryEntity?> read(String key);

  /// Reemplaza la entrada si la clave ya existe.
  Future<void> write(String key, CachedGalleryEntity entry);
}
