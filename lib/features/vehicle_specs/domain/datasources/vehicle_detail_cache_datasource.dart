import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/cached_detail_entity.dart';

/// Fuente de datos de la caché de detalles.
abstract class VehicleDetailCacheDatasource {
  Future<CachedDetailEntity?> read(String key);

  /// Reemplaza la entrada si la clave ya existe.
  Future<void> write(String key, CachedDetailEntity entry);
}
