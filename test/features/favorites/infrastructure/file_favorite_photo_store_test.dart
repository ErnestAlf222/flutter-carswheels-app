import 'dart:io';
import 'dart:typed_data';

import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// Responde con lo indicado o con una falla de red, sin salir a internet.
class _FakeAdapter implements HttpClientAdapter {
  Uint8List body = Uint8List.fromList(List<int>.filled(100, 7));
  String contentType = 'image/jpeg';
  bool offline = false;
  final List<String> urls = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    urls.add(options.uri.toString());
    if (offline) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    return ResponseBody.fromBytes(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory root;
  late _FakeAdapter adapter;
  late FileFavoritePhotoStore store;

  FileFavoritePhotoStore build({int maxBytes = 1000}) {
    final dio = Dio()..httpClientAdapter = adapter;
    return FileFavoritePhotoStore(
      directory: Directory('${root.path}/fotos'),
      dio: dio,
      maxBytes: maxBytes,
      timeout: const Duration(seconds: 5),
      downloadUrlOf: (url) => url.replaceFirst('330px', '800px'),
    );
  }

  setUp(() async {
    root = await Directory.systemTemp.createTemp('fav_photos_test');
    adapter = _FakeAdapter();
    store = build();
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('descarga a la carpeta propia con la calidad pedida', () async {
    final saved = await store.download(
      fileName: 'a.jpg',
      url: 'https://ejemplo.test/330px-a.jpg',
    );
    expect(saved, 'a.jpg');
    expect(adapter.urls.single, 'https://ejemplo.test/800px-a.jpg');
    final path = store.pathOf('a.jpg');
    expect(path, isNotNull);
    expect(File(path!).readAsBytesSync(), hasLength(100));
  });

  test('no deja restos de descarga al terminar', () async {
    await store.download(fileName: 'a.jpg', url: 'https://ejemplo.test/a');
    final names = (await store.list()).map((file) => file.name);
    expect(names, ['a.jpg']);
  });

  test('si excede el tamaño máximo no guarda nada', () async {
    adapter.body = Uint8List.fromList(List<int>.filled(5000, 1));
    final saved = await store.download(
      fileName: 'a.jpg',
      url: 'https://ejemplo.test/a',
    );
    expect(saved, isNull);
    expect(store.pathOf('a.jpg'), isNull);
    expect(await store.list(), isEmpty);
  });

  test('sin red falla sin lanzar y sin archivo', () async {
    adapter.offline = true;
    expect(
      await store.download(fileName: 'a.jpg', url: 'https://ejemplo.test/a'),
      isNull,
    );
    expect(store.pathOf('a.jpg'), isNull);
  });

  test('lo que no es una imagen no se guarda', () async {
    adapter.contentType = 'text/html';
    expect(
      await store.download(fileName: 'a.jpg', url: 'https://ejemplo.test/a'),
      isNull,
    );
  });

  test('borra solo el archivo pedido', () async {
    await store.download(fileName: 'a.jpg', url: 'https://ejemplo.test/a');
    await store.download(fileName: 'b.jpg', url: 'https://ejemplo.test/b');
    await store.delete('a.jpg');
    expect(store.pathOf('a.jpg'), isNull);
    expect(store.pathOf('b.jpg'), isNotNull);
    // Borrar lo que no existe no falla.
    await store.delete('a.jpg');
  });

  test('la lista trae nombre y fecha de modificación', () async {
    await store.download(fileName: 'a.jpg', url: 'https://ejemplo.test/a');
    final files = await store.list();
    expect(files.single.name, 'a.jpg');
    expect(
      DateTime.now().difference(files.single.modified).inMinutes,
      lessThan(1),
    );
  });

  test('sin carpeta aún la lista está vacía', () async {
    expect(await store.list(), isEmpty);
  });
}
