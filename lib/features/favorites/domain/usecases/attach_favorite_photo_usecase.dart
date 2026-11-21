import 'package:cars_wheels_app/features/favorites/domain/datasources/favorite_photo_store.dart';
import 'package:cars_wheels_app/features/favorites/domain/datasources/favorites_datasource.dart';
import 'package:cars_wheels_app/features/favorites/domain/services/favorite_photo_namer.dart';

/// Descarga la foto principal de un favorito y guarda su archivo local.
class AttachFavoritePhotoUseCase {
  const AttachFavoritePhotoUseCase({
    required this.datasource,
    required this.store,
    this.namer = const FavoritePhotoNamer(),
  });

  final FavoritesDatasource datasource;
  final FavoritePhotoStore store;
  final FavoritePhotoNamer namer;

  /// Sin efecto si no hay foto, ya está descargada o la descarga falla: en
  /// esos casos queda la referencia de red, sin inventar nada.
  Future<void> call(String key) async {
    final favorite = await datasource.read(key);
    final photo = favorite?.snapshot.photo;
    if (favorite == null || photo == null) return;
    final known = photo.localFileName;
    if (known != null && store.pathOf(known) != null) return;
    final fileName = namer.fileNameFor(favorite.identity);
    final saved = await store.download(
      fileName: fileName,
      url: photo.thumbnailUrl,
    );
    if (saved == null) return;
    // El tamaño real se lee del archivo recién guardado; sin él queda sin medir.
    final size = await store.measure(saved);
    // Si se quitó mientras se descargaba, el archivo no se queda sin dueño.
    final current = await datasource.read(key);
    final currentPhoto = current?.snapshot.photo;
    if (current == null || currentPhoto == null) {
      await store.delete(saved);
      return;
    }
    final stored = currentPhoto.withLocalFileName(saved);
    await datasource.put(
      current.withSnapshot(
        current.snapshot.withPhoto(
          size == null
              ? stored
              : stored.withDimensions(size.width, size.height),
        ),
      ),
    );
  }
}
