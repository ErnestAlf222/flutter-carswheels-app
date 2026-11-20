import 'package:cars_wheels_app/core/config/favorites_config.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_identity.dart';

/// Nombre del archivo de la foto de un favorito, derivado de su identidad.
class FavoritePhotoNamer {
  const FavoritePhotoNamer();

  static final RegExp _nonAlphanumeric = RegExp(r'[^a-z0-9]+');
  static final RegExp _edgeDashes = RegExp(r'^-+|-+$');

  /// Mercado, año, marca y modelo legibles, más un hash de la identidad completa
  /// para que dos nombres parecidos nunca choquen.
  String fileNameFor(FavoriteIdentity identity) =>
      [
        identity.marketCode,
        '${identity.year}',
        _slug(identity.brand),
        _slug(identity.groupKey),
        _hash(identity.key),
      ].join(FavoritesConfig.photoNameSeparator) +
      FavoritesConfig.photoFileExtension;

  /// Verdadero si el nombre tiene la forma de las fotos que guarda la app.
  bool isPhotoFile(String name) =>
      name.endsWith(FavoritesConfig.photoFileExtension);

  /// Verdadero si el archivo es un resto de descarga sin terminar.
  bool isPartialFile(String name) =>
      name.endsWith(FavoritesConfig.photoTempExtension);

  String _slug(String text) {
    final slug = text
        .toLowerCase()
        .replaceAll(_nonAlphanumeric, '-')
        .replaceAll(_edgeDashes, '');
    return slug.length <= FavoritesConfig.photoSlugMaxLength
        ? slug
        : slug.substring(0, FavoritesConfig.photoSlugMaxLength);
  }

  // Hash estable (FNV-1a de 32 bits) de la clave de identidad.
  String _hash(String text) {
    int value = 0x811c9dc5;
    for (final unit in text.codeUnits) {
      value = ((value ^ unit) * 0x01000193) & 0xffffffff;
    }
    return value.toRadixString(16).padLeft(8, '0');
  }
}
