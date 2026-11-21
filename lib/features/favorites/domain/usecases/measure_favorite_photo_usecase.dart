import 'package:cars_wheels_app/features/favorites/domain/datasources/favorite_photo_store.dart';
import 'package:cars_wheels_app/features/favorites/domain/datasources/favorites_datasource.dart';

/// Completa el tamaño de la foto local de un favorito guardado antes de medirlo.
class MeasureFavoritePhotoUseCase {
  const MeasureFavoritePhotoUseCase({
    required this.datasource,
    required this.store,
  });

  final FavoritesDatasource datasource;
  final FavoritePhotoStore store;

  /// Sin efecto si no hay foto local, ya tiene tamaño o el archivo no se lee.
  Future<void> call(String key) async {
    final favorite = await datasource.read(key);
    final photo = favorite?.snapshot.photo;
    final fileName = photo?.localFileName;
    if (favorite == null ||
        photo == null ||
        fileName == null ||
        photo.hasDimensions) {
      return;
    }
    final size = await store.measure(fileName);
    if (size == null) return;
    // Se relee: si cambió mientras se medía, se parte de lo más reciente.
    final current = await datasource.read(key);
    final currentPhoto = current?.snapshot.photo;
    if (current == null || currentPhoto == null) return;
    await datasource.put(
      current.withSnapshot(
        current.snapshot.withPhoto(
          currentPhoto.withDimensions(size.width, size.height),
        ),
      ),
    );
  }
}
