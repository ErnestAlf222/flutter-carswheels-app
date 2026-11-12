import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final savedAt = DateTime.fromMillisecondsSinceEpoch(1700000000000);

  CachedPhotoEntity roundTrip(CachedPhotoEntity entity) =>
      CachedPhotoMapper.toEntity(CachedPhotoMapper.toModel('clave', entity));

  test('ida y vuelta con foto', () {
    final entity = CachedPhotoEntity(
      photo: const PhotoEntity(
        thumbnailUrl: 'miniatura',
        authorName: 'autor',
        licenseName: 'CC BY 4.0',
        sourceUrl: 'fuente',
        isReference: true,
      ),
      savedAt: savedAt,
    );
    expect(roundTrip(entity), entity);
    expect(CachedPhotoMapper.toModel('clave', entity).found, isTrue);
  });

  test('ida y vuelta con fallo', () {
    final entity = CachedPhotoEntity(photo: null, savedAt: savedAt);
    final result = roundTrip(entity);
    expect(result, entity);
    expect(result.isMiss, isTrue);
    expect(CachedPhotoMapper.toModel('clave', entity).found, isFalse);
  });

  test('ida y vuelta con autor vacío', () {
    final entity = CachedPhotoEntity(
      photo: const PhotoEntity(
        thumbnailUrl: 'miniatura',
        authorName: '',
        licenseName: 'CC0',
        sourceUrl: 'fuente',
        isReference: false,
      ),
      savedAt: savedAt,
    );
    expect(roundTrip(entity).photo?.authorName, isEmpty);
    expect(roundTrip(entity), entity);
  });
}
