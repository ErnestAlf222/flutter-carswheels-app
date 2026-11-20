import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_identity.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_snapshot_entity.dart';

/// Resuelve la instantánea de un modelo; la implementa la capa app con las cachés.
abstract class FavoriteSnapshotSource {
  /// Nula si no se puede resolver (otro mercado, sin red y sin caché).
  Future<FavoriteSnapshotEntity?> snapshotOf(FavoriteIdentity identity);
}
