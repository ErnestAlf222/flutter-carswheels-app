import 'dart:io';

import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../support/isar_test_support.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late IsarPhotoCacheDatasource datasource;

  setUpAll(() async {
    await IsarTestSupport.prepare();
  });

  setUp(() async {
    if (IsarTestSupport.skipIfUnavailable()) return;
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
    if (IsarTestSupport.skipReason != null) return;
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
    if (IsarTestSupport.skipIfUnavailable()) return;
    expect(await datasource.read('nada'), isNull);
  });

  test('escribe y lee una entrada', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await datasource.write('clave', entry);
    expect(await datasource.read('clave'), entry);
  });

  test('escribir una clave existente la reemplaza', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await datasource.write('clave', entry);
    final miss = CachedPhotoEntity(photo: null, savedAt: entry.savedAt);
    await datasource.write('clave', miss);
    expect(await datasource.read('clave'), miss);
    expect(await isar.cachedPhotoModels.count(), 1);
  });
}
