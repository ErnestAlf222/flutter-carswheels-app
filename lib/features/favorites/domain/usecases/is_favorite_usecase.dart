import 'package:cars_wheels_app/features/favorites/domain/datasources/favorites_datasource.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_identity.dart';

/// Consulta si una identidad está guardada.
class IsFavoriteUseCase {
  const IsFavoriteUseCase(this.datasource);

  final FavoritesDatasource datasource;

  Future<bool> call(FavoriteIdentity identity) async =>
      await datasource.read(identity.key) != null;
}
