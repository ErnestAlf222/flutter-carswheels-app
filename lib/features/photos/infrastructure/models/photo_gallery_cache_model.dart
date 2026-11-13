import 'package:isar_community/isar.dart';

part 'photo_gallery_cache_model.g.dart';

/// Galería de fotos de un modelo guardada en Isar.
@collection
class PhotoGalleryCacheModel {
  PhotoGalleryCacheModel({
    required this.key,
    required this.payload,
    required this.savedAtMillis,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única: escribir una clave existente reemplaza la entrada.
  @Index(unique: true, replace: true)
  final String key;

  /// JSON con la lista de fotos; una lista vacía significa "no hay".
  final String payload;
  final int savedAtMillis;
}
