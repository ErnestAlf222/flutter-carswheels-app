import 'package:cars_wheels_app/features/favorites/domain/datasources/favorites_datasource.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_snapshot_entity.dart';

/// Completa la instantánea de un favorito ya guardado.
class CompleteFavoriteSnapshotUseCase {
  const CompleteFavoriteSnapshotUseCase(this.datasource);

  final FavoritesDatasource datasource;

  /// Sin efecto si el favorito ya no está (se quitó mientras se resolvía).
  Future<void> call(String key, FavoriteSnapshotEntity snapshot) async {
    final existing = await datasource.read(key);
    if (existing == null || existing.snapshot == snapshot) return;
    await datasource.put(existing.withSnapshot(snapshot));
  }
}
