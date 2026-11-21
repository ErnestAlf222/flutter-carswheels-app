import 'dart:convert';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/favorites_photo_test_support.dart';
import '../../../support/favorites_test_support.dart';

FavoritePhotoEntity _photo({
  double? aspect,
  int? width,
  int? height,
  String? local,
}) => FavoritePhotoEntity(
  thumbnailUrl: 'https://ejemplo.test/a.jpg',
  authorName: 'Ana',
  licenseName: 'CC BY-SA 4.0',
  sourceUrl: 'https://ejemplo.test/origen',
  isReference: false,
  aspectRatio: aspect,
  widthPixels: width,
  heightPixels: height,
  localFileName: local,
);

void main() {
  group('proporción de la foto', () {
    test('sin foto o sin dato usa la de por defecto', () {
      expect(
        FavoritePhotoProportion.of(null),
        FavoritesConfig.mosaicDefaultPhotoAspect,
      );
      expect(
        FavoritePhotoProportion.of(_photo()),
        FavoritesConfig.mosaicDefaultPhotoAspect,
      );
    });

    test('usa el tamaño real antes que la proporción de la fuente', () {
      expect(
        FavoritePhotoProportion.of(
          _photo(aspect: 1.4, width: 1000, height: 800),
        ),
        1.25,
      );
    });

    test('sin tamaño real usa la proporción de la fuente', () {
      expect(FavoritePhotoProportion.of(_photo(aspect: 1.2)), 1.2);
    });

    test('se limita al rango configurado', () {
      expect(
        FavoritePhotoProportion.of(_photo(width: 3000, height: 1000)),
        FavoritesConfig.mosaicMaxPhotoAspect,
      );
      expect(
        FavoritePhotoProportion.of(_photo(width: 500, height: 1000)),
        FavoritesConfig.mosaicMinPhotoAspect,
      );
    });

    test('un tamaño en cero no divide: cae a la de por defecto', () {
      expect(
        FavoritePhotoProportion.of(_photo(width: 0, height: 0)),
        FavoritesConfig.mosaicDefaultPhotoAspect,
      );
    });
  });

  group('guardado del tamaño', () {
    test('ida y vuelta conserva ancho y alto', () {
      final favorite = testFavorite(
        savedAt: DateTime.fromMillisecondsSinceEpoch(1760000000000),
        snapshot: FavoriteSnapshotEntity(
          photo: _photo(width: 960, height: 640, local: 'a.jpg'),
        ),
      );
      final back = FavoritePayloadMapper.fromPayload(
        FavoritePayloadMapper.toPayload(favorite),
      );
      expect(back.snapshot.photo!.widthPixels, 960);
      expect(back.snapshot.photo!.heightPixels, 640);
    });

    test('lo guardado antes, sin ancho ni alto, se lee igual', () {
      final favorite = testFavorite(
        savedAt: DateTime.fromMillisecondsSinceEpoch(1760000000000),
        snapshot: FavoriteSnapshotEntity(photo: _photo(local: 'a.jpg')),
      );
      final json = jsonDecode(
        FavoritePayloadMapper.toPayload(favorite),
      ) as Map<String, dynamic>;
      final photo =
          json[FavoritesConfig.payloadPhotoKey] as Map<String, dynamic>
            ..remove(FavoritesConfig.payloadPhotoWidthKey)
            ..remove(FavoritesConfig.payloadPhotoHeightKey);
      expect(photo.containsKey(FavoritesConfig.payloadPhotoWidthKey), isFalse);
      final back = FavoritePayloadMapper.fromPayload(jsonEncode(json));
      expect(back.snapshot.photo!.widthPixels, isNull);
      expect(back.snapshot.photo!.localFileName, 'a.jpg');
    });
  });

  group('medición', () {
    late InMemoryFavoritesDatasource datasource;
    late FakeFavoritePhotoStore store;

    setUp(() {
      datasource = InMemoryFavoritesDatasource();
      store = FakeFavoritePhotoStore();
    });

    test('al descargar la foto guarda su tamaño real', () async {
      final favorite = testFavorite(
        snapshot: FavoriteSnapshotEntity(photo: testFavoritePhoto()),
      );
      await datasource.put(favorite);
      await AttachFavoritePhotoUseCase(datasource: datasource, store: store)(
        favorite.key,
      );
      final saved = (await datasource.read(favorite.key))!.snapshot.photo!;
      expect(saved.widthPixels, 960);
      expect(saved.heightPixels, 640);
    });

    test(
      'un favorito antiguo con archivo se completa de forma perezosa',
      () async {
        store.files['a.jpg'] = DateTime(2026, 1, 1);
        final favorite = testFavorite(
          snapshot: FavoriteSnapshotEntity(
            photo: testFavoritePhoto(localFileName: 'a.jpg'),
          ),
        );
        await datasource.put(favorite);
        final measure = MeasureFavoritePhotoUseCase(
          datasource: datasource,
          store: store,
        );
        await measure(favorite.key);
        expect(
          (await datasource.read(favorite.key))!.snapshot.photo!.widthPixels,
          960,
        );
      },
    );

    test(
      'si el archivo no se puede leer queda sin medir, sin inventar',
      () async {
        store.files['a.jpg'] = DateTime(2026, 1, 1);
        store.size = null;
        final favorite = testFavorite(
          snapshot: FavoriteSnapshotEntity(
            photo: testFavoritePhoto(localFileName: 'a.jpg'),
          ),
        );
        await datasource.put(favorite);
        await MeasureFavoritePhotoUseCase(datasource: datasource, store: store)(
          favorite.key,
        );
        expect(
          (await datasource.read(favorite.key))!.snapshot.photo!.widthPixels,
          isNull,
        );
      },
    );
  });
}
