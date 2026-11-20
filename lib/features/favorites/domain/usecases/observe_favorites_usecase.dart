import 'package:cars_wheels_app/features/favorites/domain/datasources/favorites_datasource.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_entity.dart';

/// Los favoritos, del más reciente al más antiguo.
class ObserveFavoritesUseCase {
  const ObserveFavoritesUseCase(this.datasource);

  final FavoritesDatasource datasource;

  Stream<List<FavoriteEntity>> call() => datasource.watchAll().map(sortRecent);

  /// Orden por fecha descendente; con la misma fecha, por clave.
  static List<FavoriteEntity> sortRecent(List<FavoriteEntity> favorites) =>
      [...favorites]..sort((a, b) {
        final byDate = b.savedAt.compareTo(a.savedAt);
        return byDate != 0 ? byDate : a.key.compareTo(b.key);
      });
}
