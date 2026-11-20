import 'package:cars_wheels_app/features/favorites/domain/datasources/favorite_photo_store.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_entity.dart';

/// Borra el archivo de la foto de un favorito que ya no está.
class DeleteFavoritePhotoUseCase {
  const DeleteFavoritePhotoUseCase(this.store);

  final FavoritePhotoStore store;

  Future<void> call(FavoriteEntity favorite) async {
    final fileName = favorite.snapshot.photo?.localFileName;
    if (fileName != null) await store.delete(fileName);
  }
}
