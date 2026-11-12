import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryCache implements PhotoCacheDatasource {
  final Map<String, CachedPhotoEntity> entries = {};
  final List<int> writes = [0];

  @override
  Future<CachedPhotoEntity?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, CachedPhotoEntity entry) async {
    writes[0]++;
    entries[key] = entry;
  }
}

class _FakePhotosRepository implements PhotosRepository {
  _FakePhotosRepository({this.candidates = const []});

  List<PhotoCandidateEntity> candidates;
  AppFailure? error;
  final List<int> calls = [0];

  @override
  Future<List<PhotoCandidateEntity>> searchCandidates(String searchTerm) async {
    calls[0]++;
    final failure = error;
    if (failure != null) throw failure;
    return candidates;
  }
}

const PhotoCandidateEntity _civic = PhotoCandidateEntity(
  title: 'File:2020 Honda Civic Sedan.jpg',
  thumbnailUrl: 'nueva',
  authorName: 'autor',
  licenseName: 'CC BY-SA 4.0',
  sourceUrl: 'fuente',
  rank: 1,
);

const PhotoEntity _oldPhoto = PhotoEntity(
  thumbnailUrl: 'vieja',
  authorName: 'autor',
  licenseName: 'CC BY-SA 4.0',
  sourceUrl: 'fuente',
  isReference: false,
);

const String _civicKey = 'honda|civic|2020';

void main() {
  final now = DateTime(2026, 6, 1);
  late _MemoryCache cache;
  late _FakePhotosRepository repository;
  late ResolveModelPhotoUseCase useCase;

  setUp(() {
    cache = _MemoryCache();
    repository = _FakePhotosRepository(candidates: const [_civic]);
    useCase = ResolveModelPhotoUseCase(
      cache: cache,
      getModelPhoto: GetModelPhotoUseCase(
        repository: repository,
        selector: const PhotoCandidateSelector(),
      ),
      clock: () => now,
    );
  });

  Future<PhotoEntity?> resolve({String model = 'Civic 4Dr', int year = 2020}) =>
      useCase(brand: 'Honda', modelName: model, year: year);

  CachedPhotoEntity saved(Duration age, {PhotoEntity? photo}) =>
      CachedPhotoEntity(photo: photo, savedAt: now.subtract(age));

  test('caché vigente con foto: no llama a la red', () async {
    cache.entries[_civicKey] = saved(const Duration(days: 1), photo: _oldPhoto);
    expect(await resolve(), _oldPhoto);
    expect(repository.calls[0], 0);
  });

  test('caché vigente de fallo: devuelve nulo sin red', () async {
    cache.entries[_civicKey] = saved(const Duration(days: 1));
    expect(await resolve(), isNull);
    expect(repository.calls[0], 0);
  });

  test('vencida con foto y la red responde: actualiza', () async {
    cache.entries[_civicKey] = saved(
      const Duration(days: 40),
      photo: _oldPhoto,
    );
    final photo = await resolve();
    expect(photo?.thumbnailUrl, 'nueva');
    expect(cache.entries[_civicKey]?.photo?.thumbnailUrl, 'nueva');
    expect(cache.entries[_civicKey]?.savedAt, now);
  });

  test('vencida y la red falla: devuelve la foto vieja sin guardar', () async {
    cache.entries[_civicKey] = saved(
      const Duration(days: 40),
      photo: _oldPhoto,
    );
    repository.error = const NetworkFailure('sin red');
    expect(await resolve(), _oldPhoto);
    expect(cache.writes[0], 0);
  });

  test('sin entrada y la red falla: relanza y no guarda', () async {
    repository.error = const NetworkFailure('sin red');
    await expectLater(resolve(), throwsA(const NetworkFailure('sin red')));
    expect(cache.writes[0], 0);
  });

  test('fallo vencido y la red falla: relanza sin guardar', () async {
    cache.entries[_civicKey] = saved(const Duration(days: 10));
    repository.error = const NetworkFailure('sin red');
    await expectLater(resolve(), throwsA(isA<NetworkFailure>()));
    expect(cache.writes[0], 0);
  });

  test('sin entrada y la red devuelve nulo: guarda el fallo', () async {
    repository.candidates = const [];
    expect(await resolve(), isNull);
    expect(cache.entries[_civicKey]?.isMiss, isTrue);
    expect(cache.entries[_civicKey]?.savedAt, now);
  });

  group('vigencia', () {
    test('con foto: 30 días menos un instante es vigente', () async {
      cache.entries[_civicKey] = saved(
        const Duration(days: 30) - const Duration(microseconds: 1),
        photo: _oldPhoto,
      );
      expect(await resolve(), _oldPhoto);
      expect(repository.calls[0], 0);
    });

    test('con foto: exactamente 30 días ya venció', () async {
      cache.entries[_civicKey] = saved(
        const Duration(days: 30),
        photo: _oldPhoto,
      );
      await resolve();
      expect(repository.calls[0], greaterThan(0));
    });

    test('sin foto: 3 días menos un instante es vigente', () async {
      cache.entries[_civicKey] = saved(
        const Duration(days: 3) - const Duration(microseconds: 1),
      );
      expect(await resolve(), isNull);
      expect(repository.calls[0], 0);
    });

    test('sin foto: exactamente 3 días ya venció', () async {
      cache.entries[_civicKey] = saved(const Duration(days: 3));
      await resolve();
      expect(repository.calls[0], greaterThan(0));
    });
  });

  group('clave', () {
    test('Civic 4Dr y Civic 2Dr comparten clave', () async {
      await resolve();
      final callsAfterFirst = repository.calls[0];
      await resolve(model: 'Civic 2Dr');
      expect(cache.entries.keys, [_civicKey]);
      expect(repository.calls[0], callsAfterFirst);
    });

    test('otro año usa otra clave', () async {
      await resolve();
      await resolve(year: 2021);
      expect(cache.entries.keys, [_civicKey, 'honda|civic|2021']);
    });
  });
}
