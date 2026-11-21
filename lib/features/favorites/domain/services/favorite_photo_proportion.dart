import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_photo_entity.dart';

/// Proporción (ancho / alto) con la que el mosaico dibuja la foto de un favorito.
class FavoritePhotoProportion {
  const FavoritePhotoProportion._();

  /// La real limitada al rango configurado; sin foto o sin dato, la de por defecto.
  static double of(FavoritePhotoEntity? photo) {
    final proportion = photo?.proportion;
    if (proportion == null || proportion.isNaN || proportion <= 0) {
      return FavoritesConfig.mosaicDefaultPhotoAspect;
    }
    return proportion.clamp(
      FavoritesConfig.mosaicMinPhotoAspect,
      FavoritesConfig.mosaicMaxPhotoAspect,
    );
  }
}
