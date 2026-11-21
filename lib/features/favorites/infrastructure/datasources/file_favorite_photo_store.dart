import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';

import 'package:cars_wheels_app/core/config/favorites_config.dart';
import 'package:cars_wheels_app/features/favorites/domain/domain.dart';

/// Fotos de favoritos en una carpeta propia del disco.
class FileFavoritePhotoStore implements FavoritePhotoStore {
  const FileFavoritePhotoStore({
    required this.directory,
    required this.dio,
    required this.maxBytes,
    required this.timeout,
    required this.downloadUrlOf,
  });

  /// Carpeta de las fotos; las pruebas dan una temporal.
  final Directory directory;
  final Dio dio;
  final int maxBytes;
  final Duration timeout;

  /// Da la URL con la calidad (ancho) que se descarga a partir de la guardada.
  final String Function(String url) downloadUrlOf;

  static const String _imageContentTypePrefix = 'image/';

  @override
  String? pathOf(String fileName) {
    final file = File('${directory.path}/$fileName');
    return file.existsSync() ? file.path : null;
  }

  @override
  Future<String?> download({
    required String fileName,
    required String url,
  }) async {
    final target = File('${directory.path}/$fileName');
    final temp = File('${target.path}${FavoritesConfig.photoTempExtension}');
    try {
      final bytes = await _fetch(downloadUrlOf(url));
      if (bytes == null) return null;
      await directory.create(recursive: true);
      // Se escribe aparte y se renombra: un corte no deja una foto a medias.
      await temp.writeAsBytes(bytes, flush: true);
      await temp.rename(target.path);
      return fileName;
    } on Object {
      await _deleteQuietly(temp);
      return null;
    }
  }

  // Descarga por partes y se detiene si pasa del máximo; nulo si no es una imagen.
  Future<List<int>?> _fetch(String url) async {
    final cancel = CancelToken();
    final response = await dio.get<ResponseBody>(
      url,
      cancelToken: cancel,
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: timeout,
        sendTimeout: timeout,
      ),
    );
    final contentType = response.headers.value(Headers.contentTypeHeader);
    final body = response.data;
    if (body == null ||
        contentType == null ||
        !contentType.startsWith(_imageContentTypePrefix)) {
      return null;
    }
    final bytes = <int>[];
    await for (final chunk in body.stream) {
      bytes.addAll(chunk);
      if (bytes.length > maxBytes) {
        cancel.cancel();
        return null;
      }
    }
    return bytes.isEmpty ? null : bytes;
  }

  @override
  Future<({int width, int height})?> measure(String fileName) async {
    final file = File('${directory.path}/$fileName');
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    try {
      if (!await file.exists()) return null;
      buffer = await ui.ImmutableBuffer.fromUint8List(await file.readAsBytes());
      // El descriptor lee el encabezado sin decodificar toda la imagen.
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final size = (width: descriptor.width, height: descriptor.height);
      return size.width > 0 && size.height > 0 ? size : null;
    } on Object {
      return null;
    } finally {
      descriptor?.dispose();
      buffer?.dispose();
    }
  }

  @override
  Future<void> delete(String fileName) =>
      _deleteQuietly(File('${directory.path}/$fileName'));

  Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Si no se puede borrar ahora, la limpieza de huérfanos lo hará.
    }
  }

  @override
  Future<List<StoredPhotoFile>> list() async {
    if (!await directory.exists()) return const [];
    final files = <StoredPhotoFile>[];
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      files.add(
        StoredPhotoFile(
          name: entity.uri.pathSegments.last,
          modified: (await entity.stat()).modified,
        ),
      );
    }
    return files;
  }
}
