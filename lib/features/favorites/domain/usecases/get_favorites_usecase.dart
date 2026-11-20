import 'package:cars_wheels_app/features/favorites/domain/datasources/favorites_datasource.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_entity.dart';
import 'package:cars_wheels_app/features/favorites/domain/usecases/observe_favorites_usecase.dart';

/// Lee los favoritos una vez, del más reciente al más antiguo.
class GetFavoritesUseCase {
  const GetFavoritesUseCase(this.datasource);

  final FavoritesDatasource datasource;

  Future<List<FavoriteEntity>> call() async =>
      ObserveFavoritesUseCase.sortRecent(await datasource.readAll());
}
