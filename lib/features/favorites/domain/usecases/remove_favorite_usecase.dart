import 'package:cars_wheels_app/features/favorites/domain/datasources/favorites_datasource.dart';

/// Quita un favorito por su clave; sin efecto si no estaba.
class RemoveFavoriteUseCase {
  const RemoveFavoriteUseCase(this.datasource);

  final FavoritesDatasource datasource;

  Future<void> call(String key) => datasource.remove(key);
}
