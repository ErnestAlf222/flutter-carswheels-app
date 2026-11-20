import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/cached_detail_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_option_entity.dart';

/// Fuente de datos de la caché de detalles.
abstract class VehicleDetailCacheDatasource {
  Future<CachedDetailEntity?> read(String key);

  /// Reemplaza la entrada si la clave ya existe.
  Future<void> write(String key, CachedDetailEntity entry);
}

/// Caché de las versiones de cada variante; sirve para abrir Detalle sin red.
abstract class GroupOptionsCacheDatasource {
  /// Nulo si nunca se guardó esa clave.
  Future<List<VehicleOptionEntity>?> read(String key);

  /// Reemplaza la entrada si la clave ya existe.
  Future<void> write(String key, List<VehicleOptionEntity> options);
}
