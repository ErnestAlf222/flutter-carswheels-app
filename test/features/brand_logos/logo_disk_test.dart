import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:flutter_test/flutter_test.dart';

const String _svg = '<svg xmlns="http://www.w3.org/2000/svg"><rect/></svg>';
const String _pinned = LogosConfig.logosBaseUrl;

// Entrega el cuerpo dado en lugar de ir a la red, y cuenta las descargas.
class _TestLoader extends DiskFirstSvgLoader {
  _TestLoader(
    super.url, {
    required super.store,
    required super.fileName,
    this.body,
  });

  /// Nulo simula la falta de red.
  final String? body;
  // Lista final: la clase es inmutable y no puede llevar un contador que cambie.
  final List<int> downloadLog = [];
  int get downloads => downloadLog.length;

  @override
  Future<Uint8List?> downloadSvg() async {
    downloadLog.add(1);
    final text = body;
    if (text == null) throw const SocketException('sin red');
    return Uint8List.fromList(utf8.encode(text));
  }
}

class _MemoryStore implements LogoFileStore {
  final Map<String, String> files = {};
  final List<String> discarded = [];

  @override
  Future<String?> read(String fileName) async => files[fileName];

  @override
  Future<void> write(String fileName, String content) async =>
      files[fileName] = content;

  @override
  Future<void> discard(String fileName) async {
    discarded.add(fileName);
    files.remove(fileName);
  }
}

class _FailingDatasource implements BrandLogosDatasource {
  int calls = 0;

  @override
  Future<Map<String, String>> fetchManifest() async {
    calls++;
    throw const NetworkFailure('sin red');
  }
}

class _OkDatasource implements BrandLogosDatasource {
  int calls = 0;

  @override
  Future<Map<String, String>> fetchManifest() async {
    calls++;
    return {'Audi': 'audi.svg'};
  }
}

void main() {
  const namer = LogoFileNamer();

  group('auditoría de versión fijada', () {
    test('la base de logos lleva el hash completo, nunca "latest"', () {
      expect(LogosConfig.logosVersion, matches(RegExp(r'^[0-9a-f]{40}$')));
      expect(
        LogosConfig.logosBaseUrl,
        contains('@${LogosConfig.logosVersion}/'),
      );
      expect(LogosConfig.logosBaseUrl, isNot(contains('latest')));
    });

    test('toda URL de logo del manifiesto sale con la versión fijada', () {
      final urls = BrandLogosMapper.toLogoUrls({
        'Audi': 'audi.svg',
        'BMW': 'bmw.svg',
      }).values;
      expect(urls, isNotEmpty);
      for (final url in urls) {
        expect(url, startsWith(LogosConfig.logosBaseUrl));
        expect(url, contains('@${LogosConfig.logosVersion}/'));
      }
    });

    test('una URL del CDN sin hash fijado no se guarda en disco', () {
      expect(
        namer.svgFileNameFor(
          '${LogosConfig.logosBaseUrlHost}gh/x/y@latest/a.svg',
        ),
        isNull,
      );
      expect(
        namer.svgFileNameFor('${LogosConfig.logosBaseUrlHost}gh/x/y/a.svg'),
        isNull,
      );
    });
  });

  group('LogoFileNamer', () {
    test('el nombre lleva marca, versión fijada y regla', () {
      final name = namer.svgFileNameFor('${_pinned}audi.svg')!;
      final version = LogosConfig.logosVersion.substring(
        0,
        LogoDiskConfig.versionPrefixLength,
      );
      expect(name, 'audi__${version}__${LogoDiskConfig.formatVersion}.svg');
    });

    test('otra versión fijada es otro archivo', () {
      final other = _pinned.replaceAll(LogosConfig.logosVersion, 'a' * 40);
      expect(
        namer.svgFileNameFor('${other}audi.svg'),
        isNot(namer.svgFileNameFor('${_pinned}audi.svg')),
      );
    });

    test('marcas distintas, archivos distintos; la misma marca, el mismo', () {
      expect(
        namer.svgFileNameFor('${_pinned}audi.svg'),
        namer.svgFileNameFor('${_pinned}audi.svg'),
      );
      expect(
        namer.svgFileNameFor('${_pinned}audi.svg'),
        isNot(namer.svgFileNameFor('${_pinned}bmw.svg')),
      );
    });

    test('un logo de Commons lleva el hash de su URL', () {
      final a = namer.svgFileNameFor(
        'https://upload.wikimedia.org/a/Tesla.svg',
      );
      final b = namer.svgFileNameFor(
        'https://upload.wikimedia.org/b/Tesla.svg',
      );
      expect(a, isNotNull);
      expect(a, isNot(b));
      expect(a, contains(LogoDiskConfig.commonsVersionTag));
    });

    test('lo que no es SVG no se guarda', () {
      expect(namer.svgFileNameFor('${_pinned}audi.png'), isNull);
    });

    test('el manifiesto lleva la versión fijada', () {
      final name = namer.manifestFileNameFor(LogosConfig.logosBaseUrl)!;
      expect(name, endsWith('.json'));
      expect(name, contains(LogosConfig.logosVersion.substring(0, 12)));
    });
  });

  group('FileLogoFileStore', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('logos_test');
    });

    tearDown(() async {
      if (await directory.exists()) await directory.delete(recursive: true);
    });

    FileLogoFileStore build({int maxFile = 1000, int maxTotal = 100000}) =>
        FileLogoFileStore(
          directory: Directory('${directory.path}/logos'),
          maxFileBytes: maxFile,
          maxTotalBytes: maxTotal,
        );

    test('guarda y lee el texto tal cual', () async {
      final store = build();
      await store.write('audi__v1__f1.svg', _svg);
      expect(await store.read('audi__v1__f1.svg'), _svg);
    });

    test('un archivo que no existe da nulo', () async {
      expect(await build().read('no-esta.svg'), isNull);
    });

    test('un archivo corrupto se descarta', () async {
      final store = build();
      await store.write('a__v1__f1.svg', _svg);
      final file = File('${directory.path}/logos/a__v1__f1.svg');
      await file.writeAsBytes([0xff, 0xfe, 0xfa]);
      expect(await store.read('a__v1__f1.svg'), isNull);
      expect(file.existsSync(), isFalse);
    });

    test('un archivo que pasa del máximo se descarta al leerlo', () async {
      final store = build(maxFile: 40);
      await Directory('${directory.path}/logos').create();
      await File('${directory.path}/logos/a__v1__f1.svg').writeAsString(_svg);
      expect(await store.read('a__v1__f1.svg'), isNull);
    });

    test('no guarda un archivo que pasa del máximo por archivo', () async {
      final store = build(maxFile: 10);
      await store.write('a__v1__f1.svg', _svg);
      expect(await store.read('a__v1__f1.svg'), isNull);
    });

    test(
      'al guardar una versión nueva borra las viejas de esa marca',
      () async {
        final store = build();
        await store.write('audi__v1__f1.svg', _svg);
        await store.write('bmw__v1__f1.svg', _svg);
        await store.write('audi__v2__f1.svg', _svg);
        expect(await store.read('audi__v1__f1.svg'), isNull);
        expect(await store.read('audi__v2__f1.svg'), _svg);
        // Las otras marcas no se tocan.
        expect(await store.read('bmw__v1__f1.svg'), _svg);
      },
    );

    test(
      'pasado el total borra primero lo más antiguo, no lo recién guardado',
      () async {
        final store = build(maxTotal: _svg.length * 2);
        await store.write('a__v1__f1.svg', _svg);
        await File('${directory.path}/logos/a__v1__f1.svg')
            .setLastModified(DateTime(2020));
        await store.write('b__v1__f1.svg', _svg);
        await store.write('c__v1__f1.svg', _svg);
        final names = Directory('${directory.path}/logos')
            .listSync()
            .map((entity) => entity.uri.pathSegments.last)
            .toSet();
        expect(names, {'b__v1__f1.svg', 'c__v1__f1.svg'});
      },
    );
  });

  group('DiskFirstSvgLoader', () {
    const url = '${_pinned}audi.svg';
    final fileName = namer.svgFileNameFor(url);

    test('con el logo en disco no pide nada a la red', () async {
      final store = _MemoryStore()..files[fileName!] = _svg;
      final loader = _TestLoader(
        url,
        store: store,
        fileName: fileName,
        body: _svg,
      );
      final bytes = await loader.prepareMessage(null);
      expect(utf8.decode(bytes!), _svg);
      expect(loader.downloads, 0);
    });

    test('sin logo en disco lo pide, lo sanea y lo guarda', () async {
      final store = _MemoryStore();
      final loader = _TestLoader(
        url,
        store: store,
        fileName: fileName,
        body: _svg,
      );
      await loader.prepareMessage(null);
      await Future<void>.delayed(Duration.zero);
      expect(store.files[fileName], contains('<svg'));
    });

    test('un archivo sin <svg> se descarta y se vuelve a pedir', () async {
      final store = _MemoryStore()..files[fileName!] = 'basura';
      final loader = _TestLoader(
        url,
        store: store,
        fileName: fileName,
        body: _svg,
      );
      await loader.prepareMessage(null);
      await Future<void>.delayed(Duration.zero);
      expect(loader.downloads, 1);
      expect(store.discarded, [fileName]);
      expect(store.files[fileName], contains('<svg'));
    });

    test('sin red y sin archivo falla como antes, sin inventar nada', () async {
      final loader = _TestLoader(
        url,
        store: _MemoryStore(),
        fileName: fileName,
      );
      expect(loader.prepareMessage(null), throwsA(anything));
    });

    test('lo que guarda ya está saneado y sanear de nuevo no lo cambia', () {
      const sanitizer = SvgSanitizer();
      const dirty =
          '<svg xmlns="http://www.w3.org/2000/svg"><style>.a{fill:#fff}</style>'
          '<g class="a"><switch><rect/></switch></g></svg>';
      final once = sanitizer.sanitize(dirty);
      expect(sanitizer.sanitize(once), once);
    });
  });

  group('manifiesto en disco', () {
    test('con el manifiesto guardado no usa la red', () async {
      final store = _MemoryStore();
      final name = namer.manifestFileNameFor(LogosConfig.logosBaseUrl)!;
      store.files[name] = jsonEncode({'Audi': 'audi.svg'});
      final datasource = _FailingDatasource();
      final repository = BrandLogosRepositoryImpl(datasource, store: store);
      final urls = await repository.getLogoUrlsByBrand();
      expect(urls.values.single, '${_pinned}audi.svg');
      expect(datasource.calls, 0);
    });

    test(
      'la primera vez lo pide y lo deja guardado para sin conexión',
      () async {
        final store = _MemoryStore();
        final datasource = _OkDatasource();
        await BrandLogosRepositoryImpl(
          datasource,
          store: store,
        ).getLogoUrlsByBrand();
        expect(datasource.calls, 1);
        // Otra sesión, sin red: sale del disco.
        final offline = _FailingDatasource();
        final urls = await BrandLogosRepositoryImpl(
          offline,
          store: store,
        ).getLogoUrlsByBrand();
        expect(urls, isNotEmpty);
        expect(offline.calls, 0);
      },
    );

    test('un manifiesto ilegible se descarta y se pide de nuevo', () async {
      final store = _MemoryStore();
      final name = namer.manifestFileNameFor(LogosConfig.logosBaseUrl)!;
      store.files[name] = '{no es json';
      final datasource = _OkDatasource();
      final urls = await BrandLogosRepositoryImpl(
        datasource,
        store: store,
      ).getLogoUrlsByBrand();
      expect(urls, isNotEmpty);
      expect(datasource.calls, 1);
      expect(store.discarded, [name]);
    });

    test('sin disco ni red sigue fallando con la falla de red', () async {
      final repository = BrandLogosRepositoryImpl(_FailingDatasource());
      expect(repository.getLogoUrlsByBrand(), throwsA(isA<NetworkFailure>()));
    });
  });
}
