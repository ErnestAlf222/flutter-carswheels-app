import 'package:isar_community/isar.dart';

part 'cached_photo_model.g.dart';

/// Entrada de la caché de fotos guardada en Isar.
@collection
class CachedPhotoModel {
  CachedPhotoModel({
    required this.key,
    required this.found,
    required this.thumbnailUrl,
    required this.authorName,
    required this.licenseName,
    required this.sourceUrl,
    required this.isReference,
    required this.savedAtMillis,
    this.aspectRatio,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única: escribir una clave existente reemplaza la entrada.
  @Index(unique: true, replace: true)
  final String key;

  /// Falso significa que se buscó y no hay foto.
  final bool found;
  final String thumbnailUrl;
  final String authorName;
  final String licenseName;
  final String sourceUrl;
  final bool isReference;

  /// Nulo si no se conoce la proporción de la miniatura.
  final double? aspectRatio;
  final int savedAtMillis;
}
