import 'dart:convert';
import 'dart:io';

import 'package:cars_wheels_app/features/brand_logos/domain/domain.dart';

/// Logos y manifiesto en una carpeta del disco, con tope por archivo y en total.
class FileLogoFileStore implements LogoFileStore {
  FileLogoFileStore({
    required this.directory,
    required this.maxFileBytes,
    required this.maxTotalBytes,
    this.namer = const LogoFileNamer(),
  });

  /// Carpeta de los logos; las pruebas dan una temporal.
  final Directory directory;
  final int maxFileBytes;
  final int maxTotalBytes;
  final LogoFileNamer namer;

  File _fileOf(String fileName) => File('${directory.path}/$fileName');

  @override
  Future<String?> read(String fileName) async {
    final file = _fileOf(fileName);
    try {
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      // Pasado de tamaño o con bytes que no son UTF-8: está dañado, se descarta.
      if (bytes.length > maxFileBytes) {
        await discard(fileName);
        return null;
      }
      return utf8.decode(bytes);
    } on FormatException {
      await discard(fileName);
      return null;
    } on FileSystemException {
      return null;
    }
  }

  @override
  Future<void> write(String fileName, String content) async {
    final bytes = utf8.encode(content);
    if (bytes.length > maxFileBytes) return;
    try {
      await directory.create(recursive: true);
      final target = _fileOf(fileName);
      // Se escribe aparte y se renombra: un corte no deja un archivo a medias.
      final temp = File('${target.path}.tmp');
      await temp.writeAsBytes(bytes, flush: true);
      await temp.rename(target.path);
      await _pruneOldVersions(fileName);
      await _enforceTotalLimit(keep: fileName);
    } on FileSystemException {
      // Sin escribir, el logo se vuelve a pedir a la red cuando haga falta.
    }
  }

  @override
  Future<void> discard(String fileName) async {
    try {
      final file = _fileOf(fileName);
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Ya no está o no se puede borrar: se intentará de nuevo.
    }
  }

  // Otras versiones de la misma marca ya no sirven: la versión fijada cambió.
  Future<void> _pruneOldVersions(String fileName) async {
    final brand = namer.brandPrefixOf(fileName);
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (name != fileName && namer.brandPrefixOf(name) == brand) {
        await entity.delete();
      }
    }
  }

  // Si la carpeta pasa del total, se borran primero los archivos más antiguos.
  Future<void> _enforceTotalLimit({required String keep}) async {
    final files = <(File, int, DateTime)>[];
    int total = 0;
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      final stat = await entity.stat();
      total += stat.size;
      files.add((entity, stat.size, stat.modified));
    }
    if (total <= maxTotalBytes) return;
    files.sort((a, b) {
      final byDate = a.$3.compareTo(b.$3);
      return byDate != 0 ? byDate : a.$1.path.compareTo(b.$1.path);
    });
    for (final (file, size, _) in files) {
      if (total <= maxTotalBytes) break;
      if (file.uri.pathSegments.last == keep) continue;
      await file.delete();
      total -= size;
    }
  }
}
