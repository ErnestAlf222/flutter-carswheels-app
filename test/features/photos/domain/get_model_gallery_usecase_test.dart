import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/real_gallery_titles.dart';

class _FakePhotosRepository implements PhotosRepository {
  _FakePhotosRepository(this._responses, {this.error});

  final List<List<PhotoCandidateEntity>> _responses;
  final AppFailure? error;
  final List<String> terms = [];

  @override
  void cancelPendingSearches() {}

  @override
  Future<List<PhotoCandidateEntity>> searchCandidates(String searchTerm) async {
    terms.add(searchTerm);
    final failure = error;
    if (failure != null) throw failure;
    return _responses[terms.length - 1];
  }
}

PhotoCandidateEntity _candidate(String title, int rank, {String? source}) =>
    PhotoCandidateEntity(
      title: title,
      thumbnailUrl: 'thumb-$rank',
      authorName: 'autor',
      licenseName: 'CC BY-SA 4.0',
      sourceUrl: source ?? 'fuente-$rank',
      rank: rank,
    );

const PhotoCandidateSelector _selector = PhotoCandidateSelector();

GetModelGalleryUseCase _gallery(PhotosRepository repository) =>
    GetModelGalleryUseCase(repository: repository, selector: _selector);

GetModelPhotoUseCase _single(PhotosRepository repository) =>
    GetModelPhotoUseCase(repository: repository, selector: _selector);

List<String> _sources(List<PhotoEntity> photos) => [
  for (final photo in photos) photo.sourceUrl,
];

void main() {
  test(
    'con suficientes fotos hace una sola búsqueda y respeta el límite',
    () async {
      final repository = _FakePhotosRepository([
        candidatesFrom(corolla2020Titles),
      ]);
      final photos = await _gallery(repository)(
        brand: 'Toyota',
        modelName: 'Corolla',
        year: 2020,
      );
      expect(repository.terms, ['Toyota Corolla 2020']);
      expect(photos, hasLength(PhotosConfig.galleryMaxPhotos));
      expect(_sources(photos), [
        'fuente-1',
        'fuente-3',
        'fuente-4',
        'fuente-5',
        'fuente-6',
        'fuente-9',
      ]);
    },
  );

  test(
    'con menos del mínimo hace la segunda búsqueda sin año y mezcla',
    () async {
      final repository = _FakePhotosRepository([
        [
          _candidate('File:2020 Toyota Corolla LE.jpg', 1, source: 'a'),
          _candidate('File:2018 Toyota Corolla SE.jpg', 2, source: 'b'),
        ],
        [
          // Repite la de 2018 y trae dos nuevas de otros años.
          _candidate('File:2018 Toyota Corolla SE.jpg', 1, source: 'b'),
          _candidate('File:2019 Toyota Corolla XLE.jpg', 2, source: 'c'),
          _candidate('File:2022 Toyota Corolla SE.jpg', 3, source: 'd'),
        ],
      ]);
      final photos = await _gallery(repository)(
        brand: 'Toyota',
        modelName: 'Corolla',
        year: 2020,
      );
      expect(repository.terms, ['Toyota Corolla 2020', 'Toyota Corolla']);
      expect(_sources(photos), ['a', 'b', 'c', 'd']);
      expect(photos.map((photo) => photo.isReference), [
        false,
        true,
        true,
        true,
      ]);
    },
  );

  test('con exactamente el mínimo no hace la segunda búsqueda', () async {
    final repository = _FakePhotosRepository([
      [
        for (final rank in [1, 2, 3])
          _candidate('File:2020 Toyota Corolla LE.jpg', rank),
      ],
    ]);
    final photos = await _gallery(repository)(
      brand: 'Toyota',
      modelName: 'Corolla',
      year: 2020,
    );
    expect(photos, hasLength(PhotosConfig.galleryMinPhotosBeforeSecondSearch));
    expect(repository.terms, hasLength(1));
  });

  test('la segunda búsqueda también respeta el límite de fotos', () async {
    final repository = _FakePhotosRepository([
      [],
      candidatesFrom(corolla2020Titles),
    ]);
    final photos = await _gallery(repository)(
      brand: 'Toyota',
      modelName: 'Corolla',
      year: 2020,
    );
    expect(photos, hasLength(PhotosConfig.galleryMaxPhotos));
    expect(repository.terms, hasLength(2));
    expect(photos.every((photo) => photo.isReference), isTrue);
  });

  test(
    'sin candidatas devuelve lista vacía tras dos búsquedas como máximo',
    () async {
      final repository = _FakePhotosRepository([[], []]);
      final photos = await _gallery(repository)(
        brand: 'Toyota',
        modelName: 'Corolla',
        year: 2020,
      );
      expect(photos, isEmpty);
      expect(repository.terms, hasLength(2));
    },
  );

  test('los términos llevan alias y modelo limpio', () async {
    final repository = _FakePhotosRepository([[], []]);
    await _gallery(repository)(
      brand: 'Ford',
      modelName: 'F150 Pickup 2WD',
      year: 2020,
    );
    expect(repository.terms, ['Ford F-150 Pickup 2020', 'Ford F-150 Pickup']);
  });

  test('un fallo de red se propaga', () async {
    final repository = _FakePhotosRepository(
      const [],
      error: const NetworkFailure('sin red'),
    );
    expect(
      _gallery(repository)(brand: 'Toyota', modelName: 'Corolla', year: 2020),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('la primera foto coincide con GetModelPhotoUseCase', () async {
    final scenarios = <List<List<PhotoCandidateEntity>>>[
      [candidatesFrom(corolla2020Titles)],
      [[], candidatesFrom(corolla2020Titles)],
      [
        [_candidate('File:2018 Toyota Corolla SE.jpg', 1)],
        [_candidate('File:2019 Toyota Corolla SE.jpg', 1, source: 'z')],
      ],
      [[], []],
    ];
    for (final responses in scenarios) {
      final gallery = await _gallery(_FakePhotosRepository(responses))(
        brand: 'Toyota',
        modelName: 'Corolla',
        year: 2020,
      );
      final single = await _single(_FakePhotosRepository(responses))(
        brand: 'Toyota',
        modelName: 'Corolla',
        year: 2020,
      );
      expect(gallery.isEmpty ? null : gallery.first, single);
    }
  });
}
