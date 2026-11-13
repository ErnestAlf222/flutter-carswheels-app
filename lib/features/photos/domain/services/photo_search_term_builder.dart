import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/services/photo_candidate_selector.dart';

/// Arma el término de búsqueda de fotos: marca y modelo limpio con alias.
class PhotoSearchTermBuilder {
  const PhotoSearchTermBuilder({required this.selector});

  final PhotoCandidateSelector selector;

  /// Término sin año: marca y modelo limpio con su alias, si lo tiene.
  String base({required String brand, required String modelName}) {
    final cleanModel = selector.cleanModelName(modelName);
    return [
      brand,
      _applyAlias(cleanModel),
    ].join(PhotosConfig.searchTermSeparator);
  }

  /// Término base seguido del año.
  String withYear({
    required String brand,
    required String modelName,
    required int year,
  }) {
    final term = base(brand: brand, modelName: modelName);
    return '$term${PhotosConfig.searchTermSeparator}$year';
  }

  // Reemplaza la primera palabra por su alias, si tiene uno.
  String _applyAlias(String cleanModel) {
    final words = cleanModel.split(PhotosConfig.searchTermSeparator);
    final alias = PhotosConfig
        .photoSearchTermAliases[TextNormalizer.normalize(words.first)];
    if (alias == null) return cleanModel;
    return [alias, ...words.skip(1)].join(PhotosConfig.searchTermSeparator);
  }
}
