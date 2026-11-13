import 'package:cars_wheels_app/core/core.dart';

/// Construye la clave de caché del detalle de una versión.
class VehicleDetailKeyBuilder {
  const VehicleDetailKeyBuilder();

  /// Versión de la clave y id del vehículo, unidos por el separador.
  String build(int id) {
    return [
      VehicleSpecsConfig.vehicleDetailCacheKeyVersion,
      '$id',
    ].join(PhotosConfig.cacheKeySeparator);
  }
}
