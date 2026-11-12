import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/services/photo_candidate_selector.dart';

/// Construye la clave de foto de un modelo: marca, modelo limpio y año.
class PhotoKeyBuilder {
  const PhotoKeyBuilder({required this.selector});

  final PhotoCandidateSelector selector;

  /// Marca y modelo limpio normalizados y año, unidos por el separador.
  String build({
    required String brand,
    required String modelName,
    required int year,
  }) {
    final cleanModel = selector.cleanModelName(modelName);
    return [
      TextNormalizer.normalize(brand),
      TextNormalizer.normalize(cleanModel),
      '$year',
    ].join(PhotosConfig.cacheKeySeparator);
  }
}
