import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/photos_test_support.dart';

class _MemoryCache implements GalleryCacheDatasource {
  final Map<String, CachedGalleryEntity> entries = {};
  final List<int> writes = [0];

  @override
  Future<CachedGalleryEntity?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, CachedGalleryEntity entry) async {
    writes[0]++;
    entries[key] = entry;
  }
}

class _FakePhotosRepository implements PhotosRepository {
  List<PhotoCandidateEntity> candidates = const [];
  AppFailure? error;
  final List<int> calls = [0];

  @override
  void cancelPendingSearches() {}

  @override
  Future<List<PhotoCandidateEntity>> searchCandidates(String searchTerm) async {
    calls[0]++;
    final failure = error;
    if (failure != null) throw failure;
    return candidates;
  }
}

List<PhotoCandidateEntity> _civics() => [
  for (final rank in [1, 2, 3])
    PhotoCandidateEntity(
      title: 'File:2020 Honda Civic Sedan $rank.jpg',
      thumbnailUrl: 'nueva-$rank',
      authorName: 'autor',
      licenseName: 'CC BY-SA 4.0',
      sourceUrl: 'fuente-$rank',
      rank: rank,
    ),
];

const PhotoEntity _oldPhoto = PhotoEntity(
  thumbnailUrl: 'vieja',
  authorName: 'autor',
  licenseName: 'CC BY-SA 4.0',
  sourceUrl: 'vieja-1',
  isReference: false,
);

void main() {
  final now = DateTime(2026, 6, 1);
  late _MemoryCache cache;
  late _FakePhotosRepository repository;
  late ResolveModelGalleryUseCase useCase;
  final key = [
    PhotosConfig.galleryCacheKeyVersion,
    PhotosConfig.galleryCacheKeyTag,
    photoKeyFor('Honda', 'Civic', 2020),
  ].join('|');

  setUp(() {
    cache = _MemoryCache();
    repository = _FakePhotosRepository()..candidates = _civics();
    useCase = ResolveModelGalleryUseCase(
      cache: cache,
      getGallery: GetModelGalleryUseCase(
        repository: repository,
        selector: const PhotoCandidateSelector(),
      ),
      keyBuilder: const PhotoKeyBuilder(selector: PhotoCandidateSelector()),
      clock: () => now,
    );
  });

  Future<List<PhotoEntity>> resolve() =>
      useCase(brand: 'Honda', modelName: 'Civic 4Dr', year: 2020);

  void seed(List<PhotoEntity> photos, Duration age) {
    cache.entries[key] = CachedGalleryEntity(
      photos: photos,
      savedAt: now.subtract(age),
    );
  }

  test('la clave lleva versión, etiqueta y la clave completa de la foto', () {
    expect(key, startsWith('v2|gallery|v3|honda|civic|2020'));
    expect(
      useCase.keyFor(brand: 'Honda', modelName: 'Civic 4Dr', year: 2020),
      key,
    );
  });

  test('entrada vigente con fotos: la devuelve sin red', () async {
    seed(const [_oldPhoto], const Duration(days: 29));
    expect(await resolve(), const [_oldPhoto]);
    expect(repository.calls[0], 0);
    expect(cache.writes[0], 0);
  });

  test('entrada vigente vacía: devuelve lista vacía sin red', () async {
    seed(const [], const Duration(days: 2));
    expect(await resolve(), isEmpty);
    expect(repository.calls[0], 0);
  });

  test('límite exacto de 30 días con fotos: ya está vencida', () async {
    seed(const [_oldPhoto], const Duration(days: 30));
    final photos = await resolve();
    expect(repository.calls[0], greaterThan(0));
    expect(photos.first.sourceUrl, 'fuente-1');
  });

  test('límite exacto de 3 días vacía: ya está vencida', () async {
    seed(const [], const Duration(days: 3));
    expect(await resolve(), isNotEmpty);
    expect(repository.calls[0], greaterThan(0));
  });

  test('un minuto antes de los 3 días vacía sigue vigente', () async {
    seed(const [], const Duration(days: 3) - const Duration(minutes: 1));
    expect(await resolve(), isEmpty);
    expect(repository.calls[0], 0);
  });

  test('sin entrada busca, guarda con la clave y devuelve', () async {
    final photos = await resolve();
    expect(photos, hasLength(3));
    expect(cache.entries[key]?.photos, photos);
    expect(cache.entries[key]?.savedAt, now);
  });

  test('vencida con red: reemplaza la entrada', () async {
    seed(const [_oldPhoto], const Duration(days: 40));
    final photos = await resolve();
    expect(photos.first.sourceUrl, 'fuente-1');
    expect(cache.entries[key]?.photos, photos);
    expect(cache.writes[0], 1);
  });

  test('un resultado vacío también se guarda', () async {
    repository.candidates = const [];
    expect(await resolve(), isEmpty);
    expect(cache.entries[key]?.photos, isEmpty);
    expect(cache.writes[0], 1);
  });

  test('vencida con fotos y sin red: devuelve la vieja sin guardar', () async {
    seed(const [_oldPhoto], const Duration(days: 40));
    repository.error = const NetworkFailure('sin red');
    expect(await resolve(), const [_oldPhoto]);
    expect(cache.writes[0], 0);
  });

  test('vencida vacía y sin red: relanza el fallo', () async {
    seed(const [], const Duration(days: 10));
    repository.error = const NetworkFailure('sin red');
    expect(resolve(), throwsA(isA<NetworkFailure>()));
  });

  test('sin entrada y con fallo: relanza', () async {
    repository.error = const NetworkFailure('sin red');
    expect(resolve(), throwsA(isA<NetworkFailure>()));
    expect(cache.writes[0], 0);
  });
}
