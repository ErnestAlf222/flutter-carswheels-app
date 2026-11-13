import 'dart:convert';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final savedAt = DateTime.fromMillisecondsSinceEpoch(1700000000000);
  const photo = PhotoEntity(
    thumbnailUrl: 'miniatura',
    authorName: 'autor',
    licenseName: 'CC BY 4.0',
    sourceUrl: 'fuente',
    isReference: true,
  );

  test('el payload usa las claves de PhotosConfig', () {
    final model = CachedGalleryMapper.toModel(
      'clave',
      CachedGalleryEntity(photos: const [photo], savedAt: savedAt),
    );
    final decoded = jsonDecode(model.payload) as List<dynamic>;
    expect(decoded.single, {
      PhotosConfig.galleryPayloadThumbnailKey: 'miniatura',
      PhotosConfig.galleryPayloadAuthorKey: 'autor',
      PhotosConfig.galleryPayloadLicenseKey: 'CC BY 4.0',
      PhotosConfig.galleryPayloadSourceKey: 'fuente',
      PhotosConfig.galleryPayloadReferenceKey: true,
    });
    expect(model.key, 'clave');
    expect(model.savedAtMillis, savedAt.millisecondsSinceEpoch);
  });

  test('ida y vuelta entre entidad y modelo', () {
    final entity = CachedGalleryEntity(photos: const [photo], savedAt: savedAt);
    expect(
      CachedGalleryMapper.toEntity(CachedGalleryMapper.toModel('k', entity)),
      entity,
    );
  });

  test('un payload dañado devuelve nulo', () {
    final model = PhotoGalleryCacheModel(
      key: 'k',
      payload: '{roto',
      savedAtMillis: 0,
    );
    expect(CachedGalleryMapper.toEntity(model), isNull);
  });
}
