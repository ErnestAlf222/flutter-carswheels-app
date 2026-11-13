import 'package:cars_wheels_app/core/core.dart';

/// Construye la clave de resumen: marca, nombre del grupo y año.
class SummaryKeyBuilder {
  const SummaryKeyBuilder();

  /// Marca y grupo normalizados y año, unidos por el separador.
  String build({
    required String brand,
    required String groupName,
    required int year,
  }) {
    return [
      TextNormalizer.normalize(brand),
      TextNormalizer.normalize(groupName),
      '$year',
    ].join(PhotosConfig.cacheKeySeparator);
  }
}
