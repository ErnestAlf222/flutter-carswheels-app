import 'package:cars_wheels_app/features/favorites/favorites.dart';

/// Foto de favorito de prueba con crédito completo.
FavoritePhotoEntity testFavoritePhoto({
  String url = 'https://ejemplo.test/330px-camry.jpg',
  String? localFileName,
}) => FavoritePhotoEntity(
  thumbnailUrl: url,
  authorName: 'Ana',
  licenseName: 'CC BY-SA 4.0',
  sourceUrl: 'https://ejemplo.test/origen',
  isReference: false,
  aspectRatio: 1.5,
  localFileName: localFileName,
);

/// Carpeta de fotos en memoria con el mismo contrato que la de disco.
class FakeFavoritePhotoStore implements FavoritePhotoStore {
  /// Archivos guardados por nombre, con su fecha.
  final Map<String, DateTime> files = {};

  /// Descargas pedidas, en orden.
  final List<String> downloads = [];

  /// Nombres borrados, en orden.
  final List<String> deleted = [];

  /// Si es falso, la descarga falla (sin red o demasiado grande).
  bool downloadSucceeds = true;

  /// Si se asigna, se ejecuta a mitad de la descarga (para simular carreras).
  Future<void> Function()? duringDownload;

  DateTime now = DateTime(2026, 1, 1);

  @override
  Future<String?> download({
    required String fileName,
    required String url,
  }) async {
    downloads.add(url);
    await duringDownload?.call();
    if (!downloadSucceeds) return null;
    files[fileName] = now;
    return fileName;
  }

  @override
  Future<void> delete(String fileName) async {
    deleted.add(fileName);
    files.remove(fileName);
  }

  @override
  Future<List<StoredPhotoFile>> list() async => [
    for (final entry in files.entries)
      StoredPhotoFile(name: entry.key, modified: entry.value),
  ];

  @override
  String? pathOf(String fileName) =>
      files.containsKey(fileName) ? '/fotos/$fileName' : null;
}
