import 'package:cars_wheels_app/features/favorites/domain/entities/stored_photo_file.dart';

/// Carpeta de fotos de favoritos en disco; la capa de datos la implementa.
abstract class FavoritePhotoStore {
  /// Descarga [url] a [fileName]; el nombre si quedó guardada, nulo si falló o
  /// excede el tamaño máximo (entonces solo queda la referencia de red).
  Future<String?> download({required String fileName, required String url});

  /// Ancho y alto en píxeles del archivo guardado; nulo si no existe o no se lee.
  Future<({int width, int height})?> measure(String fileName);

  /// Borra el archivo; sin efecto si no existe.
  Future<void> delete(String fileName);

  /// Archivos de la carpeta con su fecha de modificación.
  Future<List<StoredPhotoFile>> list();

  /// Ruta completa del archivo si existe; nula si no está.
  String? pathOf(String fileName);
}
