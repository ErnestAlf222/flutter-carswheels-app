import 'package:cars_wheels_app/core/core.dart';

/// Manifiesto de logos: nombre de marca → nombre de archivo.
class BrandLogosManifestModel {
  const BrandLogosManifestModel({required this.fileNamesByBrand});

  /// Falla con ParsingFailure si no es un mapa de textos a textos.
  factory BrandLogosManifestModel.fromJson(Object? json) {
    if (json is! Map<Object?, Object?>) {
      throw const ParsingFailure('El manifiesto de logos no es un objeto JSON');
    }
    final fileNames = <String, String>{};
    for (final entry in json.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is! String || value is! String) {
        throw ParsingFailure('La entrada $key del manifiesto no es texto');
      }
      fileNames[key] = value;
    }
    return BrandLogosManifestModel(fileNamesByBrand: fileNames);
  }

  final Map<String, String> fileNamesByBrand;
}
