import 'dart:io';

import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la base de logos termina en barra y el manifiesto es json', () {
    expect(LogosConfig.logosBaseUrl, endsWith('/'));
    expect(LogosConfig.manifestFileName, endsWith('.json'));
    expect(LogosConfig.svgExtension, '.svg');
  });

  test('la base de logos usa la versión fijada y no la rama main', () {
    expect(LogosConfig.logosVersion, matches(RegExp(r'^[0-9a-f]{40}$')));
    expect(LogosConfig.logosBaseUrl, contains('@${LogosConfig.logosVersion}/'));
    expect(LogosConfig.logosBaseUrl, isNot(contains('@main')));
    expect(LogosConfig.logosSourceLabel, 'logos');
  });

  test('los alias tienen claves y valores no vacíos', () {
    expect(LogosConfig.brandAliases, isNotEmpty);
    for (final alias in LogosConfig.brandAliases.entries) {
      expect(alias.key, isNotEmpty);
      expect(alias.value, isNotEmpty);
    }
  });

  test('las medidas del carrusel son coherentes', () {
    expect(CarouselConfig.visibleBrandCount, 4);
    expect(
      CarouselConfig.brandLogoSize,
      lessThan(CarouselConfig.brandTileSize),
    );
  });

  test('selectedRing usa el grosor como spreadRadius sin desenfoque', () {
    final ring = AppShadows.selectedRing(3);
    expect(ring.spreadRadius, 3);
    expect(ring.blurRadius, 0);
    expect(ring.color, AppColors.gradientStart);
  });

  test('brandTileLabel antepone Marca', () {
    expect(AppTexts.brandTileLabel('Audi'), 'Marca Audi');
  });

  test('las cabeceras de logos llevan solo el User-Agent configurado', () {
    expect(LogosConfig.requestHeaders, {
      HttpHeaders.userAgentHeader: UserAgentsConfig.logosUserAgent,
    });
  });
}
