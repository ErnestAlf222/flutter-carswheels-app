import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_entity.dart';

/// Favoritos guardados; el almacenamiento lo decide la capa de datos.
abstract class FavoritesDatasource {
  Future<List<FavoriteEntity>> readAll();

  /// Nulo si la identidad no está guardada.
  Future<FavoriteEntity?> read(String key);

  /// Guarda o reemplaza el favorito de esa clave.
  Future<void> put(FavoriteEntity favorite);

  Future<void> remove(String key);

  /// Emite la lista completa al empezar y con cada cambio.
  Stream<List<FavoriteEntity>> watchAll();
}
