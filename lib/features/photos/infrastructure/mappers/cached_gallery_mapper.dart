import 'dart:convert';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/domain.dart';
import 'package:cars_wheels_app/features/photos/infrastructure/models/photo_gallery_cache_model.dart';

/// Convierte entre la galería guardada en Isar y la entidad de caché.
class CachedGalleryMapper {
  const CachedGalleryMapper._();

  /// Un payload dañado se trata como sin entrada (nulo).
  static CachedGalleryEntity? toEntity(PhotoGalleryCacheModel model) {
    try {
      final decoded = jsonDecode(model.payload) as List<dynamic>;
      final photos = [
        for (final item in decoded)
          _photoFromJson(item as Map<String, dynamic>),
      ];
      return CachedGalleryEntity(
        photos: photos,
        savedAt: DateTime.fromMillisecondsSinceEpoch(model.savedAtMillis),
      );
    } on Object {
      return null;
    }
  }

  static PhotoGalleryCacheModel toModel(
    String key,
    CachedGalleryEntity entity,
  ) {
    return PhotoGalleryCacheModel(
      key: key,
      payload: jsonEncode([for (final photo in entity.photos) _toJson(photo)]),
      savedAtMillis: entity.savedAt.millisecondsSinceEpoch,
    );
  }

  static Map<String, Object> _toJson(PhotoEntity photo) => {
    PhotosConfig.galleryPayloadThumbnailKey: photo.thumbnailUrl,
    PhotosConfig.galleryPayloadAuthorKey: photo.authorName,
    PhotosConfig.galleryPayloadLicenseKey: photo.licenseName,
    PhotosConfig.galleryPayloadSourceKey: photo.sourceUrl,
    PhotosConfig.galleryPayloadReferenceKey: photo.isReference,
  };

  static PhotoEntity _photoFromJson(Map<String, dynamic> json) => PhotoEntity(
    thumbnailUrl: json[PhotosConfig.galleryPayloadThumbnailKey] as String,
    authorName: json[PhotosConfig.galleryPayloadAuthorKey] as String,
    licenseName: json[PhotosConfig.galleryPayloadLicenseKey] as String,
    sourceUrl: json[PhotosConfig.galleryPayloadSourceKey] as String,
    isReference: json[PhotosConfig.galleryPayloadReferenceKey] as bool,
  );
}
