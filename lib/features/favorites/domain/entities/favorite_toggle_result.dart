import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_entity.dart';

/// Resultado de alternar un favorito.
sealed class FavoriteToggleResult {
  const FavoriteToggleResult(this.favorite);

  /// El favorito que se agregó o se quitó.
  final FavoriteEntity favorite;
}

/// No estaba: ahora está guardado.
class FavoriteAdded extends FavoriteToggleResult {
  const FavoriteAdded(super.favorite);
}

/// Estaba: ya no está.
class FavoriteRemoved extends FavoriteToggleResult {
  const FavoriteRemoved(super.favorite);
}
