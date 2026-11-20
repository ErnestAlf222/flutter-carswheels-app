import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/favorites_photo_test_support.dart';
import '../../../support/favorites_test_support.dart';

void main() {
  group('FavoritePhotoNamer', () {
    const namer = FavoritePhotoNamer();

    test('el nombre sale de la identidad y es estable', () {
      final name = namer.fileNameFor(favoriteIdentity());
      expect(name, namer.fileNameFor(favoriteIdentity()));
      expect(name, startsWith('us_2025_toyota_camry_'));
      expect(name, endsWith(FavoritesConfig.photoFileExtension));
    });

    test('identidades distintas dan nombres distintos', () {
      final names = {
        namer.fileNameFor(favoriteIdentity()),
        namer.fileNameFor(favoriteIdentity(year: 2024)),
        namer.fileNameFor(favoriteIdentity(marketCode: 'mx')),
        namer.fileNameFor(favoriteIdentity(model: 'Corolla')),
      };
      expect(names, hasLength(4));
    });

    test('solo lleva letras, números y guiones, sin rutas ni espacios', () {
      final name = namer.fileNameFor(
        favoriteIdentity(brand: 'Mercedes-Benz / AMG', model: 'Clase C ../x'),
      );
      expect(name, matches(RegExp(r'^[a-z0-9_.\-]+$')));
      expect(name, isNot(contains('/')));
    });

    test('marcas y modelos largos se acortan', () {
      final name = namer.fileNameFor(
        favoriteIdentity(model: 'a' * 200, brand: 'b' * 200),
      );
      expect(name.length, lessThan(100));
    });

    test('distingue fotos de restos de descarga y de archivos ajenos', () {
      expect(namer.isPhotoFile('us_2025_toyota_camry_ab12cd34.jpg'), isTrue);
      expect(namer.isPartialFile('x.jpg.part'), isTrue);
      expect(namer.isPhotoFile('notas.txt'), isFalse);
    });
  });

  group('FavoriteOrphanPlanner', () {
    const planner = FavoriteOrphanPlanner();
    final now = DateTime(2026, 1, 1, 12);
    const grace = Duration(minutes: 10);
    final old = now.subtract(const Duration(hours: 1));
    final recent = now.subtract(const Duration(minutes: 1));

    List<String> plan(List<StoredPhotoFile> stored, Set<String> referenced) =>
        planner.orphansOf(
          stored: stored,
          referenced: referenced,
          now: now,
          grace: grace,
        );

    test('borra la foto que ningún favorito usa', () {
      expect(plan([StoredPhotoFile(name: 'a.jpg', modified: old)], {}), [
        'a.jpg',
      ]);
    });

    test('no toca las fotos de otros favoritos', () {
      expect(
        plan(
          [
            StoredPhotoFile(name: 'a.jpg', modified: old),
            StoredPhotoFile(name: 'b.jpg', modified: old),
          ],
          {'a.jpg'},
        ),
        ['b.jpg'],
      );
    });

    test('no toca lo reciente: puede ser una descarga en curso', () {
      expect(
        plan([StoredPhotoFile(name: 'a.jpg', modified: recent)], {}),
        isEmpty,
      );
    });

    test('no toca archivos que no son de la app', () {
      expect(
        plan([StoredPhotoFile(name: 'notas.txt', modified: old)], {}),
        isEmpty,
      );
    });

    test('limpia restos de descargas viejas', () {
      expect(plan([StoredPhotoFile(name: 'a.jpg.part', modified: old)], {}), [
        'a.jpg.part',
      ]);
    });
  });

  group('AttachFavoritePhotoUseCase', () {
    late InMemoryFavoritesDatasource datasource;
    late FakeFavoritePhotoStore store;
    late AttachFavoritePhotoUseCase attach;

    setUp(() {
      datasource = InMemoryFavoritesDatasource();
      store = FakeFavoritePhotoStore();
      attach = AttachFavoritePhotoUseCase(datasource: datasource, store: store);
    });

    FavoriteEntity withPhoto([FavoritePhotoEntity? photo]) => testFavorite(
      snapshot: FavoriteSnapshotEntity(photo: photo ?? testFavoritePhoto()),
    );

    test(
      'descarga la foto y guarda su archivo local con el crédito intacto',
      () async {
        final favorite = withPhoto();
        await datasource.put(favorite);
        await attach(favorite.key);
        final saved = (await datasource.read(favorite.key))!.snapshot.photo!;
        expect(saved.localFileName, isNotNull);
        expect(store.files.keys, [saved.localFileName]);
        // El crédito CC BY sigue igual que antes de bajar la foto.
        expect(saved.authorName, 'Ana');
        expect(saved.licenseName, 'CC BY-SA 4.0');
        expect(saved.sourceUrl, 'https://ejemplo.test/origen');
      },
    );

    test('si la descarga falla conserva solo la referencia de red', () async {
      store.downloadSucceeds = false;
      final favorite = withPhoto();
      await datasource.put(favorite);
      await attach(favorite.key);
      expect(
        (await datasource.read(favorite.key))!.snapshot.photo!.localFileName,
        isNull,
      );
    });

    test('sin foto en la instantánea no descarga nada', () async {
      final favorite = testFavorite();
      await datasource.put(favorite);
      await attach(favorite.key);
      expect(store.downloads, isEmpty);
    });

    test('si ya está descargada no la repite', () async {
      final favorite = withPhoto();
      await datasource.put(favorite);
      await attach(favorite.key);
      await attach(favorite.key);
      expect(store.downloads, hasLength(1));
    });

    test('si se quita mientras baja, borra el archivo sin dueño', () async {
      final favorite = withPhoto();
      await datasource.put(favorite);
      store.duringDownload = () => datasource.remove(favorite.key);
      await attach(favorite.key);
      expect(store.files, isEmpty);
      expect(store.deleted, hasLength(1));
    });

    test('un archivo local que ya no existe se vuelve a bajar', () async {
      final favorite = withPhoto(
        testFavoritePhoto(localFileName: 'perdido.jpg'),
      );
      await datasource.put(favorite);
      await attach(favorite.key);
      expect(store.downloads, hasLength(1));
    });
  });

  group('DeleteFavoritePhotoUseCase y limpieza de huérfanos', () {
    test('borra el archivo del favorito', () async {
      final store = FakeFavoritePhotoStore()..files['a.jpg'] = DateTime(2026);
      await DeleteFavoritePhotoUseCase(store)(
        testFavorite(
          snapshot: FavoriteSnapshotEntity(
            photo: testFavoritePhoto(localFileName: 'a.jpg'),
          ),
        ),
      );
      expect(store.files, isEmpty);
    });

    test('sin archivo local no borra nada', () async {
      final store = FakeFavoritePhotoStore();
      await DeleteFavoritePhotoUseCase(store)(testFavorite());
      expect(store.deleted, isEmpty);
    });

    test('la limpieza conserva las fotos de favoritos guardados', () async {
      final datasource = InMemoryFavoritesDatasource([
        testFavorite(
          snapshot: FavoriteSnapshotEntity(
            photo: testFavoritePhoto(localFileName: 'mia.jpg'),
          ),
        ),
      ]);
      final store = FakeFavoritePhotoStore()
        ..files['mia.jpg'] = DateTime(2026, 1, 1)
        ..files['huerfana.jpg'] = DateTime(2026, 1, 1)
        ..files['reciente.jpg'] = DateTime(2026, 6, 1, 11, 59);
      final cleaned = await CleanOrphanFavoritePhotosUseCase(
        datasource: datasource,
        store: store,
        clock: () => DateTime(2026, 6, 1, 12),
        grace: const Duration(minutes: 10),
      )();
      expect(cleaned, 1);
      expect(store.files.keys, unorderedEquals(['mia.jpg', 'reciente.jpg']));
    });
  });

  group('CompleteFavoriteSnapshotUseCase y el archivo local', () {
    test('la misma foto conserva su archivo ya descargado', () async {
      final favorite = testFavorite(
        snapshot: FavoriteSnapshotEntity(
          photo: testFavoritePhoto(localFileName: 'a.jpg'),
        ),
      );
      final datasource = InMemoryFavoritesDatasource([favorite]);
      await CompleteFavoriteSnapshotUseCase(datasource)(
        favorite.key,
        FavoriteSnapshotEntity(label: 'Mediano', photo: testFavoritePhoto()),
      );
      final saved = (await datasource.read(favorite.key))!.snapshot;
      expect(saved.label, 'Mediano');
      expect(saved.photo!.localFileName, 'a.jpg');
    });

    test('otra foto no hereda el archivo de la anterior', () async {
      final favorite = testFavorite(
        snapshot: FavoriteSnapshotEntity(
          photo: testFavoritePhoto(localFileName: 'a.jpg'),
        ),
      );
      final datasource = InMemoryFavoritesDatasource([favorite]);
      await CompleteFavoriteSnapshotUseCase(datasource)(
        favorite.key,
        FavoriteSnapshotEntity(
          photo: testFavoritePhoto(url: 'https://ejemplo.test/otra.jpg'),
        ),
      );
      expect(
        (await datasource.read(favorite.key))!.snapshot.photo!.localFileName,
        isNull,
      );
    });
  });

  test('FavoritePayloadMapper guarda el archivo local y lee lo viejo sin él', () {
    final favorite = testFavorite(
      savedAt: DateTime.fromMillisecondsSinceEpoch(1760000000000),
      snapshot: FavoriteSnapshotEntity(
        photo: testFavoritePhoto(localFileName: 'a.jpg'),
      ),
    );
    final payload = FavoritePayloadMapper.toPayload(favorite);
    expect(FavoritePayloadMapper.fromPayload(payload), favorite);
    // Lo guardado antes de las fotos locales no trae la clave y sigue legible.
    final legacy = payload.replaceAll(
      ',"${FavoritesConfig.payloadPhotoLocalKey}":"a.jpg"',
      '',
    );
    expect(legacy, isNot(contains('"local"')));
    expect(
      FavoritePayloadMapper.fromPayload(legacy).snapshot.photo!.localFileName,
      isNull,
    );
  });
}
