import 'dart:async';

import 'package:cars_wheels_app/features/favorites/favorites.dart';

/// Identidad de prueba: Toyota Camry 2025 de EE. UU. salvo que se indique otra.
FavoriteIdentity favoriteIdentity({
  String model = 'Camry',
  String brand = 'Toyota',
  int year = 2025,
  String marketCode = 'us',
}) => FavoriteIdentity(
  marketCode: marketCode,
  year: year,
  brand: brand,
  groupKey: model.toLowerCase().replaceAll(' ', ''),
  modelName: model,
);

/// Favorito de prueba con fecha y, si se pide, instantánea.
FavoriteEntity testFavorite({
  String model = 'Camry',
  String brand = 'Toyota',
  int year = 2025,
  String marketCode = 'us',
  DateTime? savedAt,
  FavoriteSnapshotEntity snapshot = FavoriteSnapshotEntity.empty,
}) => FavoriteEntity(
  identity: favoriteIdentity(
    model: model,
    brand: brand,
    year: year,
    marketCode: marketCode,
  ),
  savedAt: savedAt ?? DateTime(2026, 1, 1),
  snapshot: snapshot,
);

/// Favoritos en memoria con el mismo contrato que el de Isar.
class InMemoryFavoritesDatasource implements FavoritesDatasource {
  InMemoryFavoritesDatasource([List<FavoriteEntity> initial = const []]) {
    for (final favorite in initial) {
      _items[favorite.key] = favorite;
    }
  }

  final Map<String, FavoriteEntity> _items = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Cuántas escrituras hubo, para comprobar que no se repiten sin motivo.
  int writes = 0;

  @override
  Future<List<FavoriteEntity>> readAll() async => _items.values.toList();

  @override
  Future<FavoriteEntity?> read(String key) async => _items[key];

  @override
  Future<void> put(FavoriteEntity favorite) async {
    writes++;
    _items[favorite.key] = favorite;
    _changes.add(null);
  }

  @override
  Future<void> remove(String key) async {
    _items.remove(key);
    _changes.add(null);
  }

  @override
  Stream<List<FavoriteEntity>> watchAll() {
    // Se suscribe al cambiar antes de emitir: no se pierde ninguna escritura.
    late final StreamController<List<FavoriteEntity>> controller;
    StreamSubscription<void>? subscription;
    controller = StreamController<List<FavoriteEntity>>(
      onListen: () {
        subscription = _changes.stream.listen(
          (_) => controller.add(_items.values.toList()),
        );
        controller.add(_items.values.toList());
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }
}

/// Fuente de instantáneas de prueba: respuesta por modelo, con espera y fallas.
class FakeFavoriteSnapshotSource implements FavoriteSnapshotSource {
  final Map<String, FavoriteSnapshotEntity?> snapshots = {};

  /// Si se asigna, la respuesta espera a que se complete.
  Completer<void>? gate;

  /// Modelos cuya resolución lanza.
  final Set<String> failing = {};
  int requests = 0;

  @override
  Future<FavoriteSnapshotEntity?> snapshotOf(FavoriteIdentity identity) async {
    requests++;
    await gate?.future;
    if (failing.contains(identity.modelName)) throw StateError('sin red');
    return snapshots[identity.modelName];
  }
}

/// Cubit de favoritos sobre fuentes de prueba.
FavoritesCubit buildFavoritesCubit({
  FavoritesDatasource? datasource,
  FavoriteSnapshotSource? snapshotSource,
  DateTime Function()? clock,
  Duration messageDuration = const Duration(seconds: 30),
  Duration undoDuration = const Duration(seconds: 30),
  AttachFavoritePhotoUseCase? attachPhoto,
  DeleteFavoritePhotoUseCase? deletePhoto,
}) {
  final store = datasource ?? InMemoryFavoritesDatasource();
  final now = clock ?? DateTime.now;
  return FavoritesCubit(
    observeFavorites: ObserveFavoritesUseCase(store),
    getFavorites: GetFavoritesUseCase(store),
    toggleFavorite: ToggleFavoriteUseCase(store, clock: now),
    removeFavorite: RemoveFavoriteUseCase(store),
    restoreFavorite: RestoreFavoriteUseCase(store),
    completeSnapshot: CompleteFavoriteSnapshotUseCase(store),
    snapshotSource: snapshotSource ?? FakeFavoriteSnapshotSource(),
    attachPhoto: attachPhoto,
    deletePhoto: deletePhoto,
    clock: now,
    messageDuration: messageDuration,
    undoDuration: undoDuration,
  );
}
