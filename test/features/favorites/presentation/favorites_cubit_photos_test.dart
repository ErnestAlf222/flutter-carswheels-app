import 'dart:async';

import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/favorites_photo_test_support.dart';
import '../../../support/favorites_test_support.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late InMemoryFavoritesDatasource datasource;
  late FakeFavoritePhotoStore store;
  late FakeFavoriteSnapshotSource source;
  late FavoritesCubit cubit;

  FavoriteSnapshotEntity snapshotWithPhoto() => FavoriteSnapshotEntity(
    label: 'Mediano',
    variantNames: const ['Camry LE'],
    photo: testFavoritePhoto(),
  );

  setUp(() {
    datasource = InMemoryFavoritesDatasource();
    store = FakeFavoritePhotoStore();
    source = FakeFavoriteSnapshotSource();
    cubit = buildFavoritesCubit(
      datasource: datasource,
      snapshotSource: source,
      undoDuration: const Duration(milliseconds: 80),
      messageDuration: const Duration(milliseconds: 80),
      attachPhoto: AttachFavoritePhotoUseCase(
        datasource: datasource,
        store: store,
      ),
      deletePhoto: DeleteFavoritePhotoUseCase(store),
    );
  });

  tearDown(() => cubit.close());

  Future<FavoriteEntity> saveWithLocalPhoto() async {
    final identity = favoriteIdentity();
    source.snapshots[identity.modelName] = snapshotWithPhoto();
    await cubit.toggle(identity);
    await _settle();
    final saved = (await datasource.read(identity.key))!;
    expect(saved.snapshot.photo!.localFileName, isNotNull);
    return saved;
  }

  test(
    'al guardar baja la foto en segundo plano sin bloquear el corazón',
    () async {
      await _settle();
      final gate = Completer<void>();
      store.duringDownload = () => gate.future;
      final identity = favoriteIdentity();
      source.snapshots[identity.modelName] = snapshotWithPhoto();
      await cubit.toggle(identity);
      // El toggle ya terminó aunque la descarga siga esperando.
      expect((cubit.state as FavoritesLoaded).isFavorite(identity.key), isTrue);
      await _settle();
      expect(store.files, isEmpty);
      gate.complete();
      await _settle();
      expect(store.files, hasLength(1));
      expect(
        (await datasource.read(identity.key))!.snapshot.photo!.localFileName,
        store.files.keys.single,
      );
    },
  );

  test('si la descarga falla solo queda la referencia de red', () async {
    store.downloadSucceeds = false;
    final identity = favoriteIdentity();
    source.snapshots[identity.modelName] = snapshotWithPhoto();
    await cubit.toggle(identity);
    await _settle();
    final photo = (await datasource.read(identity.key))!.snapshot.photo!;
    expect(photo.localFileName, isNull);
    expect(photo.thumbnailUrl, isNotEmpty);
  });

  test('quitar con el corazón borra el archivo de inmediato', () async {
    final saved = await saveWithLocalPhoto();
    await cubit.toggle(saved.identity);
    await _settle();
    expect(store.files, isEmpty);
  });

  test(
    'quitar desde Favoritos conserva el archivo durante "Deshacer"',
    () async {
      final saved = await saveWithLocalPhoto();
      await cubit.remove(saved);
      await _settle();
      expect(store.files, isNotEmpty);
    },
  );

  test('al vencer el plazo de "Deshacer" se borra el archivo', () async {
    final saved = await saveWithLocalPhoto();
    await cubit.remove(saved);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(store.files, isEmpty);
  });

  test(
    'deshacer conserva el archivo y el favorito vuelve con su foto',
    () async {
      final saved = await saveWithLocalPhoto();
      await cubit.remove(saved);
      await cubit.undo();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(store.files, isNotEmpty);
      expect(
        (await datasource.read(saved.key))!.snapshot.photo!.localFileName,
        saved.snapshot.photo!.localFileName,
      );
    },
  );

  test('quitar otro antes de que venza borra solo el primero', () async {
    final first = await saveWithLocalPhoto();
    final other = favoriteIdentity(model: 'Corolla');
    source.snapshots['Corolla'] = snapshotWithPhoto();
    await cubit.toggle(other);
    await _settle();
    final second = (await datasource.read(other.key))!;
    expect(store.files, hasLength(2));
    await cubit.remove(first);
    await cubit.remove(second);
    // El primero ya no se puede deshacer; el segundo sigue en su plazo.
    await _settle();
    expect(store.files.keys, [second.snapshot.photo!.localFileName]);
  });
}
