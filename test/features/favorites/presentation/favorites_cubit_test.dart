import 'dart:async';

import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/favorites_test_support.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

FavoritesLoaded _loaded(FavoritesCubit cubit) => cubit.state as FavoritesLoaded;

void main() {
  late InMemoryFavoritesDatasource store;
  late FakeFavoriteSnapshotSource source;
  late FavoritesCubit cubit;
  final ticks = <int>[];

  // Cada guardado recibe una fecha posterior para que el orden sea claro.
  DateTime clock() {
    ticks.add(ticks.length);
    return DateTime(2026, 1, 1).add(Duration(minutes: ticks.length));
  }

  setUp(() {
    ticks.clear();
    store = InMemoryFavoritesDatasource();
    source = FakeFavoriteSnapshotSource();
    cubit = buildFavoritesCubit(
      datasource: store,
      snapshotSource: source,
      clock: clock,
    );
  });

  tearDown(() => cubit.close());

  test('empieza cargando y luego queda cargado y vacío', () async {
    final fresh = buildFavoritesCubit();
    addTearDown(fresh.close);
    expect(fresh.state, isA<FavoritesLoading>());
    await _settle();
    expect(_loaded(cubit).favorites, isEmpty);
    expect(_loaded(cubit).keys, isEmpty);
  });

  test(
    'el corazón responde al instante, antes de que termine el disco',
    () async {
      await _settle();
      final identity = favoriteIdentity();
      final pending = cubit.toggle(identity);
      // Sin esperar: ya aparece como favorito (optimista).
      expect(_loaded(cubit).isFavorite(identity.key), isTrue);
      await pending;
      expect(await store.readAll(), hasLength(1));
      await _settle();
      expect(_loaded(cubit).isFavorite(identity.key), isTrue);
    },
  );

  test('alternar dos veces lo quita y avisa en cada caso', () async {
    await _settle();
    final identity = favoriteIdentity();
    await cubit.toggle(identity);
    expect(_loaded(cubit).message, FavoriteMessageKind.saved);
    await cubit.toggle(identity);
    expect(_loaded(cubit).message, FavoriteMessageKind.removed);
    expect(_loaded(cubit).isFavorite(identity.key), isFalse);
    expect(await store.readAll(), isEmpty);
  });

  test('la lista va del más reciente al más antiguo', () async {
    await _settle();
    await cubit.toggle(favoriteIdentity(model: 'A'));
    await cubit.toggle(favoriteIdentity(model: 'B'));
    await cubit.toggle(favoriteIdentity(model: 'C'));
    await _settle();
    expect(_loaded(cubit).favorites.map((favorite) => favorite.modelName), [
      'C',
      'B',
      'A',
    ]);
  });

  group('instantánea', () {
    test('se completa en cuanto llega y conserva la identidad', () async {
      await _settle();
      const snapshot = FavoriteSnapshotEntity(
        label: 'Mediano',
        engineKinds: ['hybrid'],
        minKmPerLiter: 14,
        maxKmPerLiter: 16,
      );
      source.snapshots['Camry'] = snapshot;
      await cubit.toggle(favoriteIdentity());
      await _settle();
      final saved = (await store.readAll()).single;
      expect(saved.snapshot.label, 'Mediano');
      expect(saved.snapshot.minKmPerLiter, 14);
      expect(_loaded(cubit).favorites.single.snapshot.label, 'Mediano');
    });

    test(
      'mientras se resuelve, el favorito ya está guardado sin datos',
      () async {
        await _settle();
        source.gate = Completer<void>();
        await cubit.toggle(favoriteIdentity());
        final saved = (await store.readAll()).single;
        expect(saved.snapshot.isEmpty, isTrue);
        expect(_loaded(cubit).isFavorite(favoriteIdentity().key), isTrue);
        source.gate!.complete();
      },
    );

    test(
      'si la resolución falla se queda con lo que hay, sin inventar',
      () async {
        await _settle();
        source.failing.add('Camry');
        await cubit.toggle(
          favoriteIdentity(),
          initialSnapshot: const FavoriteSnapshotEntity(variantNames: ['LE']),
        );
        await _settle();
        final saved = (await store.readAll()).single;
        expect(saved.snapshot.label, isNull);
        expect(saved.snapshot.minKmPerLiter, isNull);
        expect(saved.snapshot.variantNames, ['LE']);
      },
    );

    test(
      'si la fuente no devuelve nada, queda la instantánea inicial',
      () async {
        await _settle();
        await cubit.toggle(favoriteIdentity());
        await _settle();
        expect((await store.readAll()).single.snapshot.isEmpty, isTrue);
      },
    );

    test(
      'conserva las variantes de la tarjeta si la fuente no las trae',
      () async {
        await _settle();
        source.snapshots['Camry'] = const FavoriteSnapshotEntity(
          label: 'Mediano',
        );
        await cubit.toggle(
          favoriteIdentity(),
          initialSnapshot: const FavoriteSnapshotEntity(variantNames: ['LE']),
        );
        await _settle();
        final saved = (await store.readAll()).single;
        expect(saved.snapshot.label, 'Mediano');
        expect(saved.snapshot.variantNames, ['LE']);
      },
    );

    test(
      'al volver a guardar un modelo quitado conserva sus datos conocidos',
      () async {
        await _settle();
        const snapshot = FavoriteSnapshotEntity(
          label: 'Mediano',
          minKmPerLiter: 14,
          maxKmPerLiter: 16,
        );
        source.snapshots['Camry'] = snapshot;
        final identity = favoriteIdentity();
        await cubit.toggle(identity);
        await _settle();
        await cubit.toggle(identity);
        // Ahora la fuente ya no puede resolverlo (por ejemplo, otro mercado).
        source.snapshots['Camry'] = null;
        await cubit.toggle(identity);
        await _settle();
        final saved = (await store.readAll()).single;
        expect(saved.snapshot.label, 'Mediano');
        expect(saved.snapshot.minKmPerLiter, 14);
      },
    );

    test('si se quita mientras se resuelve, no reaparece', () async {
      await _settle();
      source.gate = Completer<void>();
      source.snapshots['Camry'] = const FavoriteSnapshotEntity(
        label: 'Mediano',
      );
      final identity = favoriteIdentity();
      await cubit.toggle(identity);
      await cubit.toggle(identity);
      source.gate!.complete();
      await _settle();
      expect(await store.readAll(), isEmpty);
    });
  });

  group('quitar con deshacer', () {
    test('quita, avisa con el nombre y restaura en su posición', () async {
      await _settle();
      await cubit.toggle(favoriteIdentity(model: 'A'));
      await cubit.toggle(favoriteIdentity(model: 'B'));
      await cubit.toggle(favoriteIdentity(model: 'C'));
      await _settle();
      final middle = _loaded(cubit).favorites[1];
      expect(middle.modelName, 'B');

      await cubit.remove(middle);
      expect(_loaded(cubit).message, FavoriteMessageKind.removedWithUndo);
      expect(_loaded(cubit).messageSubject, 'B');
      expect(_loaded(cubit).favorites.map((favorite) => favorite.modelName), [
        'C',
        'A',
      ]);

      await cubit.undo();
      await _settle();
      expect(_loaded(cubit).message, isNull);
      expect(_loaded(cubit).favorites.map((favorite) => favorite.modelName), [
        'C',
        'B',
        'A',
      ]);
      // Vuelve con su fecha original, no con la de ahora.
      expect(_loaded(cubit).favorites[1].savedAt, middle.savedAt);
      expect(await store.readAll(), hasLength(3));
    });

    test('deshacer sin nada quitado no hace nada', () async {
      await _settle();
      await cubit.undo();
      expect(_loaded(cubit).favorites, isEmpty);
    });
  });

  test('el mensaje se oculta solo pasado su tiempo', () async {
    final quick = buildFavoritesCubit(
      datasource: InMemoryFavoritesDatasource(),
      messageDuration: const Duration(milliseconds: 30),
    );
    addTearDown(quick.close);
    await _settle();
    await quick.toggle(favoriteIdentity());
    expect(_loaded(quick).message, FavoriteMessageKind.saved);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(_loaded(quick).message, isNull);
  });

  test(
    'el mensaje de deshacer dura más que el normal y puede cerrarse',
    () async {
      await _settle();
      await cubit.toggle(favoriteIdentity());
      await _settle();
      await cubit.remove(_loaded(cubit).favorites.single);
      cubit.dismissMessage();
      expect(_loaded(cubit).message, isNull);
    },
  );

  test('cada mensaje nuevo cambia su número, aunque sea el mismo', () async {
    await _settle();
    await cubit.toggle(favoriteIdentity(model: 'A'));
    final first = _loaded(cubit).messageId;
    await cubit.toggle(favoriteIdentity(model: 'B'));
    expect(_loaded(cubit).messageId, greaterThan(first));
  });
}
