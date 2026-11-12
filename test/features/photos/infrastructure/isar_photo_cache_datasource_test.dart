import 'dart:io';

import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late IsarPhotoCacheDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('isar_photo_cache');
    isar = await Isar.open(
      [CachedPhotoModelSchema],
      directory: directory.path,
      name: 'prueba',
      inspector: false,
    );
    datasource = IsarPhotoCacheDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  final entry = CachedPhotoEntity(
    photo: const PhotoEntity(
      thumbnailUrl: 'miniatura',
      authorName: 'autor',
      licenseName: 'CC BY 4.0',
      sourceUrl: 'fuente',
      isReference: false,
    ),
    savedAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
  );

  test('una clave inexistente devuelve nulo', () async {
    expect(await datasource.read('nada'), isNull);
  });

  test('escribe y lee una entrada', () async {
    await datasource.write('clave', entry);
    expect(await datasource.read('clave'), entry);
  });

  test('escribir una clave existente la reemplaza', () async {
    await datasource.write('clave', entry);
    final miss = CachedPhotoEntity(photo: null, savedAt: entry.savedAt);
    await datasource.write('clave', miss);
    expect(await datasource.read('clave'), miss);
    expect(await isar.cachedPhotoModels.count(), 1);
  });
}
