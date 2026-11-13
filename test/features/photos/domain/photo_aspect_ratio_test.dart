import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _pageWith(Map<String, dynamic> dimensions) => {
  'title': 'File:2020 Toyota Corolla LE.jpg',
  'index': 1,
  'imageinfo': [
    {
      'thumburl': 'https://upload.example/thumb/1.jpg',
      'descriptionurl': 'https://commons.example/wiki/1',
      'extmetadata': {
        'LicenseShortName': {'value': 'CC BY-SA 4.0'},
      },
      ...dimensions,
    },
  ],
};

void main() {
  group('CommonsCandidateMapper: proporción', () {
    test('calcula ancho entre alto de la miniatura', () {
      final candidate = CommonsCandidateMapper.toCandidate(
        _pageWith({
          PhotosConfig.thumbnailWidthKey: 600,
          PhotosConfig.thumbnailHeightKey: 400,
        }),
      );
      expect(candidate.aspectRatio, 1.5);
    });

    test('sin dimensiones queda nulo', () {
      final candidate = CommonsCandidateMapper.toCandidate(_pageWith({}));
      expect(candidate.aspectRatio, isNull);
    });

    test('con solo una dimensión queda nulo', () {
      final candidate = CommonsCandidateMapper.toCandidate(
        _pageWith({PhotosConfig.thumbnailWidthKey: 600}),
      );
      expect(candidate.aspectRatio, isNull);
    });

    test('con alto 0 queda nulo', () {
      final candidate = CommonsCandidateMapper.toCandidate(
        _pageWith({
          PhotosConfig.thumbnailWidthKey: 600,
          PhotosConfig.thumbnailHeightKey: 0,
        }),
      );
      expect(candidate.aspectRatio, isNull);
    });
  });

  test('el selector copia la proporción de la candidata a la foto', () {
    const candidate = PhotoCandidateEntity(
      title: 'File:2020 Toyota Corolla LE.jpg',
      thumbnailUrl: 'miniatura',
      authorName: 'autor',
      licenseName: 'CC BY-SA 4.0',
      sourceUrl: 'fuente',
      rank: 1,
      aspectRatio: 1.78,
    );
    final photo = const PhotoCandidateSelector().select(
      [candidate],
      'Toyota',
      'Corolla',
      2020,
    );
    expect(photo!.aspectRatio, 1.78);
  });

  group('PhotoFitResolver', () {
    const resolver = PhotoFitResolver();

    test('dentro del rango y nulo usan cover', () {
      for (final ratio in [1.2, 1.5, 2.4, null]) {
        expect(resolver.resolve(ratio), PhotoFitMode.cover, reason: '$ratio');
      }
    });

    test('fuera del rango usa contain', () {
      for (final ratio in [1.0, 3.0]) {
        expect(resolver.resolve(ratio), PhotoFitMode.contain, reason: '$ratio');
      }
    });

    test('los umbrales vienen de UiConfig', () {
      expect(
        resolver.resolve(UiConfig.photoCoverMinAspect - 0.01),
        PhotoFitMode.contain,
      );
      expect(
        resolver.resolve(UiConfig.photoCoverMaxAspect + 0.01),
        PhotoFitMode.contain,
      );
    });
  });

  group('cachés', () {
    test('la caché de fotos guarda y lee la proporción', () {
      final entity = CachedPhotoEntity(
        photo: const PhotoEntity(
          thumbnailUrl: 'm',
          authorName: 'a',
          licenseName: 'l',
          sourceUrl: 's',
          isReference: false,
          aspectRatio: 1.5,
        ),
        savedAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );
      final model = CachedPhotoMapper.toModel('k', entity);
      expect(model.aspectRatio, 1.5);
      expect(CachedPhotoMapper.toEntity(model), entity);
    });

    test('la caché de fotos conserva la proporción nula', () {
      final entity = CachedPhotoEntity(
        photo: const PhotoEntity(
          thumbnailUrl: 'm',
          authorName: 'a',
          licenseName: 'l',
          sourceUrl: 's',
          isReference: false,
        ),
        savedAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );
      final back = CachedPhotoMapper.toEntity(
        CachedPhotoMapper.toModel('k', entity),
      );
      expect(back.photo!.aspectRatio, isNull);
    });

    test('las versiones de las claves invalidan lo guardado antes', () {
      expect(PhotosConfig.photoCacheKeyVersion, 'v3');
      expect(PhotosConfig.galleryCacheKeyVersion, 'v2');
    });
  });
}
