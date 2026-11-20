import 'dart:io';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../support/favorites_test_support.dart';
import '../../../support/isar_test_support.dart';

const FavoriteSnapshotEntity _full = FavoriteSnapshotEntity(
  label: 'Mediano',
  engineKinds: ['hybrid', 'gasoline'],
  minKmPerLiter: 12.5,
  maxKmPerLiter: 15,
  variantNames: ['Camry LE', 'Camry XSE'],
  photo: FavoritePhotoEntity(
    thumbnailUrl: 'https://ejemplo.test/camry.jpg',
    authorName: 'Ana',
    licenseName: 'CC BY-SA 4.0',
    sourceUrl: 'https://ejemplo.test/origen',
    isReference: true,
    aspectRatio: 1.5,
  ),
);

void main() {
  group('FavoritePayloadMapper', () {
    test('la clave lleva prefijo, versión, mercado, año, marca y grupo', () {
      expect(
        FavoritePayloadMapper.keyFor(favoriteIdentity()),
        [
          FavoritesConfig.storageKeyPrefix,
          FavoritesConfig.storageKeyVersion,
          'us',
          '2025',
          'Toyota',
          'camry',
        ].join('|'),
      );
      expect(
        FavoritePayloadMapper.keyFor(favoriteIdentity()),
        'favorite|v1|us|2025|Toyota|camry',
      );
    });

    test('ida y vuelta conserva todo, incluida la foto', () {
      final favorite = testFavorite(
        savedAt: DateTime.fromMillisecondsSinceEpoch(1760000000000),
        snapshot: _full,
      );
      final back = FavoritePayloadMapper.fromPayload(
        FavoritePayloadMapper.toPayload(favorite),
      );
      expect(back, favorite);
    });

    test('los nulos siguen siendo nulos, no cero', () {
      final favorite = testFavorite(
        savedAt: DateTime.fromMillisecondsSinceEpoch(1760000000000),
        snapshot: const FavoriteSnapshotEntity(label: 'Mediano'),
      );
      final back = FavoritePayloadMapper.fromPayload(
        FavoritePayloadMapper.toPayload(favorite),
      );
      expect(back.snapshot.minKmPerLiter, isNull);
      expect(back.snapshot.maxKmPerLiter, isNull);
      expect(back.snapshot.photo, isNull);
      expect(back.snapshot.engineKinds, isEmpty);
    });

    test('un JSON con otra forma lanza para que quien lee decida', () {
      expect(
        () => FavoritePayloadMapper.fromPayload('{"market":1}'),
        throwsA(isA<Object>()),
      );
    });
  });

  group('IsarFavoritesDatasource', () {
    late Directory directory;
    late Isar isar;
    late IsarFavoritesDatasource datasource;

    Future<Isar> open() => Isar.open(
      [FavoriteModelSchema],
      directory: directory.path,
      name: 'prueba',
      inspector: false,
    );

    setUpAll(() async {
      await IsarTestSupport.prepare();
    });

    setUp(() async {
      if (IsarTestSupport.skipIfUnavailable()) return;
      directory = await Directory.systemTemp.createTemp('isar_favorites');
      isar = await open();
      datasource = IsarFavoritesDatasource(isar);
    });

    tearDown(() async {
      if (IsarTestSupport.skipReason != null) return;
      await isar.close(deleteFromDisk: true);
      await directory.delete(recursive: true);
    });

    test('guarda, lee, reemplaza por clave y quita', () async {
      if (IsarTestSupport.skipIfUnavailable()) return;
      final favorite = testFavorite(
        savedAt: DateTime.fromMillisecondsSinceEpoch(1760000000000),
      );
      await datasource.put(favorite);
      expect(await datasource.read(favorite.key), favorite);
      // Reemplazar la misma identidad no acumula filas.
      await datasource.put(favorite.withSnapshot(_full));
      expect(await isar.favoriteModels.count(), 1);
      expect((await datasource.readAll()).single.snapshot, _full);
      await datasource.remove(favorite.key);
      expect(await datasource.readAll(), isEmpty);
    });

    test('los casos de uso alternan y completan sobre Isar con claves de identidad', () async {
      if (IsarTestSupport.skipIfUnavailable()) return;
      final identity = favoriteIdentity();
      final toggle = ToggleFavoriteUseCase(datasource, clock: DateTime.now);
      expect(await toggle(identity), isA<FavoriteAdded>());
      await CompleteFavoriteSnapshotUseCase(datasource)(identity.key, _full);
      expect((await datasource.readAll()).single.snapshot, _full);
      // Alternar de nuevo lo encuentra y lo quita (no lo duplica).
      expect(await toggle(identity), isA<FavoriteRemoved>());
      expect(await datasource.readAll(), isEmpty);
      expect(await isar.favoriteModels.count(), 0);
    });

    test('sobrevive al reinicio: se reabre la base y sigue ahí', () async {
      if (IsarTestSupport.skipIfUnavailable()) return;
      final favorite = testFavorite(
        savedAt: DateTime.fromMillisecondsSinceEpoch(1760000000000),
        snapshot: _full,
      );
      await datasource.put(favorite);
      await isar.close();
      isar = await open();
      datasource = IsarFavoritesDatasource(isar);
      expect(await datasource.readAll(), [favorite]);
    });

    test(
      'lo guardado con otra versión de clave o ilegible se ignora',
      () async {
        if (IsarTestSupport.skipIfUnavailable()) return;
        await isar.writeTxn(() async {
          await isar.favoriteModels.putByKey(
            FavoriteModel(
              key: 'favorite|v0|us|2025|Toyota|camry',
              payload: '{}',
              savedAtMillis: 1,
            ),
          );
          await isar.favoriteModels.putByKey(
            FavoriteModel(
              key: 'favorite|v1|us|2025|Toyota|roto',
              payload: 'no es json',
              savedAtMillis: 1,
            ),
          );
        });
        await datasource.put(testFavorite(model: 'Corolla'));
        expect(
          (await datasource.readAll()).map((favorite) => favorite.modelName),
          ['Corolla'],
        );
      },
    );

    test('watchAll emite al empezar y con cada cambio', () async {
      if (IsarTestSupport.skipIfUnavailable()) return;
      final lengths = <int>[];
      final subscription = datasource.watchAll().listen(
        (list) => lengths.add(list.length),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await datasource.put(testFavorite());
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();
      expect(lengths.first, 0);
      expect(lengths.last, 1);
    });
  });
}
