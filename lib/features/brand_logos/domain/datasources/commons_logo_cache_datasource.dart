import 'package:cars_wheels_app/features/brand_logos/domain/entities/cached_commons_logo_entity.dart';

/// Caché de los logos de respaldo ya resueltos.
abstract class CommonsLogoCacheDatasource {
  Future<CachedCommonsLogoEntity?> read(String key);

  /// Reemplaza la entrada si la clave ya existe.
  Future<void> write(String key, CachedCommonsLogoEntity entry);
}
