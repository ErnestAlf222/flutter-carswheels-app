import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/favorites_test_support.dart';

void main() {
  late InMemoryFavoritesDatasource store;
  late DateTime now;

  setUp(() {
    store = InMemoryFavoritesDatasource();
    now = DateTime(2026, 3, 1);
  });

  ToggleFavoriteUseCase toggle() =>
      ToggleFavoriteUseCase(store, clock: () => now);

  group('ToggleFavoriteUseCase', () {
    test('agrega si no está y quita si está, con resultado tipado', () async {
      final identity = favoriteIdentity();
      final added = await toggle()(identity);
      expect(added, isA<FavoriteAdded>());
      expect(added.favorite.savedAt, now);
      expect((await store.readAll()).single.identity, identity);

      final removed = await toggle()(identity);
      expect(removed, isA<FavoriteRemoved>());
      expect(removed.favorite.identity, identity);
      expect(await store.readAll(), isEmpty);
    });

    test(
      'la identidad evita duplicados: el nombre no entra en la clave',
      () async {
        final first = favoriteIdentity(model: 'Camry');
        // Mismo mercado, año, marca y grupo con otra grafía del nombre.
        const second = FavoriteIdentity(
          marketCode: 'us',
          year: 2025,
          brand: 'Toyota',
          groupKey: 'camry',
          modelName: 'CAMRY',
        );
        expect(first.key, second.key);
        await toggle()(first);
        expect(await toggle()(second), isA<FavoriteRemoved>());
        expect(await store.readAll(), isEmpty);
      },
    );

    test('otro mercado o año es otro favorito', () async {
      await toggle()(favoriteIdentity());
      await toggle()(favoriteIdentity(marketCode: 'mx'));
      await toggle()(favoriteIdentity(year: 2024));
      expect(await store.readAll(), hasLength(3));
    });

    test(
      'guarda lo que la tarjeta ya sabía como instantánea inicial',
      () async {
        const snapshot = FavoriteSnapshotEntity(variantNames: ['Camry LE']);
        final result = await toggle()(
          favoriteIdentity(),
          initialSnapshot: snapshot,
        );
        expect(result.favorite.snapshot, snapshot);
      },
    );
  });

  group('RestoreFavoriteUseCase', () {
    test(
      'devuelve el favorito con su fecha original, en su posición',
      () async {
        final old = testFavorite(model: 'A', savedAt: DateTime(2026, 1, 1));
        final recent = testFavorite(model: 'B', savedAt: DateTime(2026, 2, 1));
        await store.put(old);
        await store.put(recent);
        await RemoveFavoriteUseCase(store)(recent.key);
        await RemoveFavoriteUseCase(store)(old.key);
        await RestoreFavoriteUseCase(store)(old);
        await RestoreFavoriteUseCase(store)(recent);
        final ordered = ObserveFavoritesUseCase.sortRecent(
          await store.readAll(),
        );
        expect(ordered.map((favorite) => favorite.modelName), ['B', 'A']);
        expect(ordered.last.savedAt, DateTime(2026, 1, 1));
      },
    );
  });

  group('ObserveFavoritesUseCase', () {
    test('emite del más reciente al más antiguo', () async {
      await store.put(testFavorite(model: 'A', savedAt: DateTime(2026, 1, 1)));
      await store.put(testFavorite(model: 'C', savedAt: DateTime(2026, 3, 1)));
      await store.put(testFavorite(model: 'B', savedAt: DateTime(2026, 2, 1)));
      final list = await ObserveFavoritesUseCase(store)().first;
      expect(list.map((favorite) => favorite.modelName), ['C', 'B', 'A']);
    });

    test('con la misma fecha desempata por clave, siempre igual', () {
      final same = DateTime(2026, 1, 1);
      final list = ObserveFavoritesUseCase.sortRecent([
        testFavorite(model: 'Zeta', savedAt: same),
        testFavorite(model: 'Alfa', savedAt: same),
      ]);
      expect(list.map((favorite) => favorite.modelName), ['Alfa', 'Zeta']);
    });

    test('emite de nuevo con cada cambio', () async {
      final emissions = <int>[];
      final subscription = ObserveFavoritesUseCase(
        store,
      )().listen((list) => emissions.add(list.length));
      await Future<void>.delayed(Duration.zero);
      await toggle()(favoriteIdentity());
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();
      expect(emissions, [0, 1]);
    });
  });

  group('instantánea', () {
    test('lo ausente queda nulo: nunca se convierte en cero', () {
      const snapshot = FavoriteSnapshotEntity(label: 'Mediano');
      expect(snapshot.minKmPerLiter, isNull);
      expect(snapshot.maxKmPerLiter, isNull);
      expect(snapshot.photo, isNull);
      expect(snapshot.isEmpty, isFalse);
      expect(FavoriteSnapshotEntity.empty.isEmpty, isTrue);
    });

    test('CompleteFavoriteSnapshot completa uno guardado', () async {
      await toggle()(favoriteIdentity());
      const snapshot = FavoriteSnapshotEntity(
        label: 'Mediano',
        minKmPerLiter: 12.5,
        maxKmPerLiter: 14,
      );
      await CompleteFavoriteSnapshotUseCase(store)(
        favoriteIdentity().key,
        snapshot,
      );
      final saved = (await store.readAll()).single;
      expect(saved.snapshot, snapshot);
      expect(saved.savedAt, now);
    });

    test('si se quitó mientras se resolvía no lo vuelve a crear', () async {
      await CompleteFavoriteSnapshotUseCase(store)(
        favoriteIdentity().key,
        const FavoriteSnapshotEntity(label: 'Mediano'),
      );
      expect(await store.readAll(), isEmpty);
    });

    test(
      'conserva las variantes de la tarjeta si la fuente no trae ninguna',
      () {
        const fromSource = FavoriteSnapshotEntity(label: 'Mediano');
        final merged = fromSource.withVariantsIfMissing(const ['LE', 'XLE']);
        expect(merged.variantNames, ['LE', 'XLE']);
        expect(merged.label, 'Mediano');
        expect(
          const FavoriteSnapshotEntity(variantNames: ['Otra'])
              .withVariantsIfMissing(const ['LE'])
              .variantNames,
          ['Otra'],
        );
      },
    );
  });

  test('IsFavoriteUseCase responde por identidad', () async {
    expect(await IsFavoriteUseCase(store)(favoriteIdentity()), isFalse);
    await toggle()(favoriteIdentity());
    expect(await IsFavoriteUseCase(store)(favoriteIdentity()), isTrue);
  });
}
