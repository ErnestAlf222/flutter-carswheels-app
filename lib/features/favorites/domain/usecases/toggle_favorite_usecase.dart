import 'package:cars_wheels_app/features/favorites/domain/datasources/favorites_datasource.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_entity.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_identity.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_snapshot_entity.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_toggle_result.dart';

/// Agrega el favorito si no está y lo quita si está.
class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this.datasource, {required this.clock});

  final FavoritesDatasource datasource;

  /// Reloj inyectado para controlar el tiempo en las pruebas.
  final DateTime Function() clock;

  /// [initialSnapshot] es lo que la tarjeta ya sabe del modelo al guardarlo.
  Future<FavoriteToggleResult> call(
    FavoriteIdentity identity, {
    FavoriteSnapshotEntity initialSnapshot = FavoriteSnapshotEntity.empty,
  }) async {
    final existing = await datasource.read(identity.key);
    if (existing != null) {
      await datasource.remove(identity.key);
      return FavoriteRemoved(existing);
    }
    // Se guarda al instante con la identidad; la instantánea llega después.
    final favorite = FavoriteEntity(
      identity: identity,
      savedAt: clock(),
      snapshot: initialSnapshot,
    );
    await datasource.put(favorite);
    return FavoriteAdded(favorite);
  }
}
