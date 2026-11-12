import 'dart:io';

import 'package:cars_wheels_app/core/config/user_agents_config.dart';

/// Origen y convenciones de los logos de marcas.
class LogosConfig {
  const LogosConfig._();

  // Misma instancia constante para widgets y precarga: la caché SVG usa los headers en su llave.
  static const Map<String, String> requestHeaders = {
    HttpHeaders.userAgentHeader: UserAgentsConfig.logosUserAgent,
  };

  static const String logosSourceLabel = 'logos';
  // Versión fijada el 2026-11-12; se actualiza a propósito, no de forma automática.
  static const String logosVersion = '3f0929e70e0a9a2a502063edc4b3e5c0146cba74';
  static const String logosBaseUrl =
      'https://cdn.jsdelivr.net/gh/vehiclespecs/brand-logos@$logosVersion/';
  static const String manifestFileName = 'brands.json';
  static const String svgExtension = '.svg';

  // Marcas cuyo logo sigue en blanco tras sanear; sale de la auditoría de render
  // (nonWhiteRatio < 0.02 con SvgSanitizer) y se regenera al subir logosVersion.
  // Avatr se agregó a mano: su logo se dibuja incompleto, solo la palabra.
  static const List<String> brandsWithoutUsableLogo = ['Avatr'];

  // Nombres de FuelEconomy que difieren del nombre del manifiesto.
  static const Map<String, String> brandAliases = {
    'McLaren Automotive': 'McLaren',
    'RUF Automobile': 'RUF',
    'Build Your Dreams': 'BYD',
    'Gmc': 'GMC',
    'Mg': 'MG',
    'Baic': 'BAIC',
    'Seat': 'SEAT',
    'Volkswagen Comerciales': 'Volkswagen',
    // Auditoría de cobertura del 2026-11-12 contra FuelEconomy 1984-2027.
    'Bugatti Rimac': 'Bugatti',
    'BMW Alpina': 'Alpina',
    'INEOS Automotive': 'INEOS',
    'Ruf Automobile Gmbh': 'RUF',
    'Saleen Performance': 'Saleen',
    'TVR Engineering Ltd': 'TVR',
  };
}
