import 'dart:convert';
import 'dart:typed_data';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:flutter_test/flutter_test.dart';

// Entrega bytes fijos en lugar de descargarlos, para probar sin red.
class _OfflineLoader extends SanitizedSvgNetworkLoader {
  const _OfflineLoader(this.body)
    : super(
        '${LogosConfig.logosBaseUrl}vw.svg',
        headers: LogosConfig.requestHeaders,
      );

  final String body;

  @override
  Future<Uint8List?> prepareMessage(context) async =>
      Uint8List.fromList(utf8.encode(body));

  Future<String> text() async => provideSvg(await prepareMessage(null));
}

void main() {
  test('entrega el texto sin switch', () async {
    final text = await const _OfflineLoader('<svg><switch><g/></switch></svg>')
        .text();
    expect(text, '<svg><g><g/></g></svg>');
  });

  test('entrega el texto con las clases ya en style', () async {
    final text = await const _OfflineLoader(
      '<svg><style>.a{fill:#fff}</style><path class="a" d="M0 0z"/></svg>',
    ).text();
    expect(text, isNot(contains('<style')));
    expect(text, contains('style="fill:#fff"'));
  });

  test('conserva url y cabeceras, y la llave de caché sale de ellas', () {
    const loader = _OfflineLoader('<svg/>');
    expect(loader.headers, same(LogosConfig.requestHeaders));
    // flutter_svg 2.5 compara la llave por url y cabeceras, no por el objeto.
    final key = loader.cacheKey(null);
    expect(key, const _OfflineLoader('<svg/>').cacheKey(null));
    const other = SanitizedSvgNetworkLoader('https://otra.url/vw.svg');
    expect(key, isNot(other.cacheKey(null)));
  });
}
