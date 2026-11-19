import 'dart:convert';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/commons_logo_fixtures.dart';

List<CommonsLogoCandidateEntity> _candidates(String brand) =>
    CommonsLogoDatasourceImpl.parse(jsonDecode(commonsLogoResponses[brand]!));

void main() {
  const selector = CommonsLogoSelector();

  group('con respuestas reales de Commons', () {
    test('Auteco elige el SVG con su licencia y su fuente', () {
      final logo = selector.select('Auteco', _candidates('Auteco'))!;
      expect(logo.url, contains('Auteco_logo.svg'));
      expect(logo.licenseName, 'Public domain');
      expect(logo.sourceUrl, contains('File:Auteco_logo.svg'));
    });

    test('Avatr prefiere el SVG sobre el PNG y el JPG', () {
      final logo = selector.select('Avatr', _candidates('Avatr'))!;
      expect(logo.url, contains('Avatr_Technology_logo.svg'));
      expect(logo.licenseName, 'Public domain');
      expect(logo.authorName, 'Avatr Technology Co., Ltd.');
    });

    test('Soueast usa la miniatura PNG con su licencia', () {
      final logo = selector.select('Soueast', _candidates('Soueast'))!;
      expect(logo.url, contains('Soueast_Logo.png'));
      expect(logo.licenseName, 'Public domain');
    });

    test('las URLs quedan sin parámetros de seguimiento', () {
      final svg = selector.select('Auteco', _candidates('Auteco'))!;
      final png = selector.select('Soueast', _candidates('Soueast'))!;
      expect(svg.url, endsWith(LogosConfig.svgExtension));
      expect(png.url, endsWith('.png'));
      expect(svg.url, isNot(contains('?')));
    });

    test('GAC no toma el logo de Great American Country', () {
      // GAC-logo.png es de un canal de TV: no está en categorías de vehículos.
      expect(selector.select('Gac', _candidates('Gac')), isNull);
    });

    test('sin resultados o con resultados sin relación devuelve nulo', () {
      expect(selector.select('Vizeon', _candidates('Vizeon')), isNull);
      expect(selector.select('Yudo', _candidates('Yudo')), isNull);
    });
  });

  group('reglas', () {
    CommonsLogoCandidateEntity candidate({
      String title = 'File:Foo logo.svg',
      String mime = LogosConfig.commonsSvgMime,
      String license = 'CC BY 4.0',
      List<String> categories = const ['Foo vehicles'],
      int rank = 1,
    }) => CommonsLogoCandidateEntity(
      title: title,
      fileUrl: 'https://upload.test/file',
      thumbnailUrl: 'https://thumb.test/file.png',
      mime: mime,
      licenseName: license,
      authorName: 'Autor',
      sourceUrl: 'https://commons.test/File:Foo',
      rank: rank,
      categories: categories,
    );

    test('una licencia no permitida se descarta', () {
      expect(
        selector.select('Foo', [candidate(license: 'All rights reserved')]),
        isNull,
      );
    });

    test('un JPG o un PDF se descartan', () {
      expect(selector.select('Foo', [candidate(mime: 'image/jpeg')]), isNull);
      expect(
        selector.select('Foo', [candidate(mime: 'application/pdf')]),
        isNull,
      );
    });

    test('sin categoría de vehículos se descarta', () {
      expect(
        selector.select('Foo', [
          candidate(categories: const ['Text logos']),
        ]),
        isNull,
      );
    });

    test('un título con otra palabra de marca se descarta', () {
      expect(
        selector.select('Foo', [candidate(title: 'File:Foo Bar logo.svg')]),
        isNull,
      );
    });

    test('el PNG usa la miniatura y el SVG el archivo original', () {
      final png = selector.select('Foo', [
        candidate(title: 'File:Foo logo.png', mime: LogosConfig.commonsPngMime),
      ]);
      final svg = selector.select('Foo', [candidate()]);
      expect(png!.url, 'https://thumb.test/file.png');
      expect(svg!.url, 'https://upload.test/file');
    });

    test('entre SVG y PNG gana el SVG aunque tenga peor rank', () {
      final logo = selector.select('Foo', [
        candidate(
          title: 'File:Foo logo.png',
          mime: LogosConfig.commonsPngMime,
          rank: 1,
        ),
        candidate(rank: 5),
      ]);
      expect(logo!.url, 'https://upload.test/file');
    });
  });
}
