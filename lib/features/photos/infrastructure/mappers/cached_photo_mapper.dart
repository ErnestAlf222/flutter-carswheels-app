import 'package:cars_wheels_app/features/photos/domain/entities/cached_photo_entity.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/photo_entity.dart';
import 'package:cars_wheels_app/features/photos/infrastructure/models/cached_photo_model.dart';

/// Convierte entre la entrada guardada en Isar y la entidad de caché.
class CachedPhotoMapper {
  const CachedPhotoMapper._();

  static CachedPhotoEntity toEntity(CachedPhotoModel model) {
    final photo = model.found
        ? PhotoEntity(
            thumbnailUrl: model.thumbnailUrl,
            authorName: model.authorName,
            licenseName: model.licenseName,
            sourceUrl: model.sourceUrl,
            isReference: model.isReference,
          )
        : null;
    return CachedPhotoEntity(
      photo: photo,
      savedAt: DateTime.fromMillisecondsSinceEpoch(model.savedAtMillis),
    );
  }

  /// Un fallo guardado deja los textos vacíos.
  static CachedPhotoModel toModel(String key, CachedPhotoEntity entity) {
    final photo = entity.photo;
    return CachedPhotoModel(
      key: key,
      found: photo != null,
      thumbnailUrl: photo?.thumbnailUrl ?? '',
      authorName: photo?.authorName ?? '',
      licenseName: photo?.licenseName ?? '',
      sourceUrl: photo?.sourceUrl ?? '',
      isReference: photo?.isReference ?? false,
      savedAtMillis: entity.savedAt.millisecondsSinceEpoch,
    );
  }
}
