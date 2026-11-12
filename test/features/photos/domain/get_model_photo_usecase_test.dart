import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePhotosRepository implements PhotosRepository {
  _FakePhotosRepository(this._responses, {this.error});

  final List<List<PhotoCandidateEntity>> _responses;
  final AppFailure? error;
  final List<String> terms = [];

  @override
  Future<List<PhotoCandidateEntity>> searchCandidates(String searchTerm) async {
    terms.add(searchTerm);
    final failure = error;
    if (failure != null) throw failure;
    return _responses[terms.length - 1];
  }
}

PhotoCandidateEntity _candidate(String title, int rank) => PhotoCandidateEntity(
  title: title,
  thumbnailUrl: 'thumb',
  authorName: 'autor',
  licenseName: 'licencia',
  sourceUrl: 'fuente',
  rank: rank,
);

GetModelPhotoUseCase _useCase(PhotosRepository repository) =>
    GetModelPhotoUseCase(
      repository: repository,
      selector: const PhotoCandidateSelector(),
    );

void main() {
  final matching = _candidate('File:2020 Honda Civic Sedan.jpg', 1);
  final otherYear = _candidate('File:2018 Honda Civic Sedan.jpg', 1);

  test('encuentra en la primera búsqueda y no hace la segunda', () async {
    final repository = _FakePhotosRepository([
      [matching],
    ]);
    final photo = await _useCase(repository)(
      brand: 'Honda',
      modelName: 'Civic 4Dr',
      year: 2020,
    );
    expect(photo?.isReference, isFalse);
    expect(repository.terms, ['Honda Civic 2020']);
  });

  test(
    'si la primera no encuentra, la segunda va sin año y es referencia',
    () async {
      final repository = _FakePhotosRepository([
        [],
        [otherYear],
      ]);
      final photo = await _useCase(repository)(
        brand: 'Honda',
        modelName: 'Civic 4Dr',
        year: 2020,
      );
      expect(photo?.isReference, isTrue);
      expect(repository.terms, ['Honda Civic 2020', 'Honda Civic']);
    },
  );

  test('si la segunda trae foto del año igual es referencia', () async {
    final repository = _FakePhotosRepository([
      [],
      [matching],
    ]);
    final photo = await _useCase(repository)(
      brand: 'Honda',
      modelName: 'Civic',
      year: 2020,
    );
    expect(photo?.isReference, isTrue);
  });

  test('si ninguna encuentra devuelve null tras dos búsquedas', () async {
    final repository = _FakePhotosRepository([[], []]);
    final photo = await _useCase(repository)(
      brand: 'Aston Martin',
      modelName: 'DBX',
      year: 2027,
    );
    expect(photo, isNull);
    expect(repository.terms, ['Aston Martin DBX 2027', 'Aston Martin DBX']);
  });

  test('el error del repositorio se propaga', () async {
    final repository = _FakePhotosRepository(
      [],
      error: const NetworkFailure('sin red'),
    );
    await expectLater(
      _useCase(repository)(brand: 'Honda', modelName: 'Civic', year: 2020),
      throwsA(const NetworkFailure('sin red')),
    );
    expect(repository.terms, hasLength(1));
  });
}
