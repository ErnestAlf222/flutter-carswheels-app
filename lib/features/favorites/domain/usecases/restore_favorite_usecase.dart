import 'package:cars_wheels_app/features/favorites/domain/datasources/favorites_datasource.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_entity.dart';

/// Devuelve un favorito quitado con su fecha original (para "Deshacer").
class RestoreFavoriteUseCase {
  const RestoreFavoriteUseCase(this.datasource);

  final FavoritesDatasource datasource;

  /// Conserva `savedAt`: vuelve a su posición en la lista.
  Future<void> call(FavoriteEntity favorite) => datasource.put(favorite);
}
