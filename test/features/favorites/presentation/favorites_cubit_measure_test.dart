import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/favorites_photo_test_support.dart';
import '../../../support/favorites_test_support.dart';

Future<void> _flush() async {
  for (final _ in List.generate(6, (n) => n)) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test(
    'completa de forma perezosa el tamaño de las fotos ya guardadas',
    () async {
      final store = FakeFavoritePhotoStore()
        ..files['a.jpg'] = DateTime(2026, 1, 1);
      final datasource = InMemoryFavoritesDatasource([
        testFavorite(
          snapshot: FavoriteSnapshotEntity(
            photo: testFavoritePhoto(localFileName: 'a.jpg'),
          ),
        ),
      ]);
      final cubit = buildFavoritesCubit(
        datasource: datasource,
        measurePhoto: MeasureFavoritePhotoUseCase(
          datasource: datasource,
          store: store,
        ),
      );
      addTearDown(cubit.close);
      await _flush();
      final saved = (await datasource.readAll()).single.snapshot.photo!;
      expect(saved.widthPixels, 960);
      expect(saved.heightPixels, 640);
    },
  );

  test(
    'un archivo ilegible se intenta una sola vez y no inventa tamaño',
    () async {
      final store = FakeFavoritePhotoStore()
        ..files['a.jpg'] = DateTime(2026, 1, 1)
        ..size = null;
      final datasource = InMemoryFavoritesDatasource([
        testFavorite(
          snapshot: FavoriteSnapshotEntity(
            photo: testFavoritePhoto(localFileName: 'a.jpg'),
          ),
        ),
      ]);
      final cubit = buildFavoritesCubit(
        datasource: datasource,
        measurePhoto: MeasureFavoritePhotoUseCase(
          datasource: datasource,
          store: store,
        ),
      );
      addTearDown(cubit.close);
      await _flush();
      final saved = (await datasource.readAll()).single.snapshot.photo!;
      expect(saved.widthPixels, isNull);
    },
  );

  test('el orden elegido se conserva en el estado de la sesión', () async {
    final cubit = buildFavoritesCubit(
      datasource: InMemoryFavoritesDatasource([testFavorite()]),
    );
    addTearDown(cubit.close);
    await _flush();
    expect((cubit.state as FavoritesLoaded).sortMode, FavoriteSortMode.recent);
    cubit.setSortMode(FavoriteSortMode.alphabetical);
    expect(
      (cubit.state as FavoritesLoaded).sortMode,
      FavoriteSortMode.alphabetical,
    );
    // Un mensaje nuevo no pierde el orden.
    cubit.announceAddedToCompare(2);
    final state = cubit.state as FavoritesLoaded;
    expect(state.sortMode, FavoriteSortMode.alphabetical);
    expect(state.message, FavoriteMessageKind.addedToCompare);
    cubit.dismissMessage();
  });
}
