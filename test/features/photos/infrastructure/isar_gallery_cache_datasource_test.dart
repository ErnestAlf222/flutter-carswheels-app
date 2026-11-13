import 'dart:io';

import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../support/isar_test_support.dart';

PhotoEntity _photo(int index, {bool isReference = false}) => PhotoEntity(
  thumbnailUrl: 'miniatura-$index',
  authorName: 'autor-$index',
  licenseName: 'CC BY 4.0',
  sourceUrl: 'fuente-$index',
  isReference: isReference,
);

void main() {
  late Directory directory;
  late Isar isar;
  late IsarGalleryCacheDatasource datasource;

  setUpAll(() async {
    await IsarTestSupport.prepare();
  });

  setUp(() async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    directory = await Directory.systemTemp.createTemp('isar_gallery_cache');
    isar = await Isar.open(
      [PhotoGalleryCacheModelSchema],
      directory: directory.path,
      name: 'prueba',
      inspector: false,
    );
    datasource = IsarGalleryCacheDatasource(isar);
  });

  tearDown(() async {
    if (IsarTestSupport.skipReason != null) return;
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  final savedAt = DateTime.fromMillisecondsSinceEpoch(1700000000000);

  test('una clave inexistente devuelve nulo', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    expect(await datasource.read('nada'), isNull);
  });

  test(
    'ida y vuelta con varias fotos conserva el orden y los campos',
    () async {
      if (IsarTestSupport.skipIfUnavailable()) return;
      final entry = CachedGalleryEntity(
        photos: [_photo(1), _photo(2, isReference: true), _photo(3)],
        savedAt: savedAt,
      );
      await datasource.write('clave', entry);
      expect(await datasource.read('clave'), entry);
    },
  );

  test('ida y vuelta con lista vacía', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    final entry = CachedGalleryEntity(photos: const [], savedAt: savedAt);
    await datasource.write('clave', entry);
    final read = await datasource.read('clave');
    expect(read, entry);
    expect(read?.isMiss, isTrue);
  });

  test('escribir una clave existente la reemplaza', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await datasource.write(
      'clave',
      CachedGalleryEntity(photos: [_photo(1)], savedAt: savedAt),
    );
    final replacement = CachedGalleryEntity(
      photos: [_photo(2), _photo(3)],
      savedAt: savedAt,
    );
    await datasource.write('clave', replacement);
    expect(await datasource.read('clave'), replacement);
    expect(await isar.photoGalleryCacheModels.count(), 1);
  });

  test('un payload dañado se trata como sin entrada', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    for (final payload in ['no es json', '{"a":1}', '[{"thumbnailUrl":1}]']) {
      await isar.writeTxn(
        () => isar.photoGalleryCacheModels.putByKey(
          PhotoGalleryCacheModel(
            key: 'rota',
            payload: payload,
            savedAtMillis: savedAt.millisecondsSinceEpoch,
          ),
        ),
      );
      expect(await datasource.read('rota'), isNull, reason: payload);
    }
  });
}
