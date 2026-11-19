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
  // Para estas marcas se usa el logo de respaldo de Commons si existe.
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
    // Los datos de México escriben así a Hongqi; el manifiesto la trae bien escrita.
    'Honqi': 'Hongqi',
  };

  // Logos de respaldo desde Wikimedia Commons, solo para marcas sin logo arriba.
  static const String commonsLogoSearchSuffix = 'logo';
  static const int commonsLogoSearchLimit = 10;
  // Ancho de la miniatura PNG; los SVG se piden en su archivo original.
  static const int commonsLogoThumbnailWidthPixels = 256;
  static const String commonsLogoImageInfoProperties = 'url|mime|extmetadata';
  static const String commonsLogoMimeParameter = 'iiprop';
  // Solo la licencia, el autor y las categorías: menos datos por respuesta.
  static const String commonsLogoMetadataFilterParameter =
      'iiextmetadatafilter';
  static const String commonsLogoMetadataFilter =
      'LicenseShortName|Artist|Categories';
  static const String commonsLogoUrlKey = 'url';
  static const String commonsLogoMimeKey = 'mime';
  static const String commonsSvgMime = 'image/svg+xml';
  static const String commonsPngMime = 'image/png';
  // Palabras del título que no cuentan como marca distinta (marca + logo + estas).
  static const List<String> commonsLogoNoiseWords = [
    'logo',
    'technology',
    'technologies',
    'motor',
    'motors',
    'group',
    'automobile',
    'automobiles',
    'auto',
    'png',
    'svg',
  ];
  // Categorías de Commons: el archivo debe estar en alguna de tema vehicular,
  // para no tomar el logo de otra empresa con las mismas siglas (ej. GAC).
  static const String commonsCategoriesKey = 'Categories';
  static const String commonsCategorySeparator = '|';
  static const List<String> commonsVehicleCategoryKeywords = [
    'vehicles',
    'automobile',
    'motorcycle',
    'car companies',
    'truck',
  ];
  // Licencias aceptadas, por prefijo del nombre corto que da Commons.
  static const List<String> commonsAllowedLicensePrefixes = [
    'Public domain',
    'CC0',
    'CC BY',
    'CC BY-SA',
  ];
  // Provisionales: vigencia de un logo hallado y de una búsqueda sin resultado.
  static const int commonsLogoTimeToLiveDays = 90;
  static const int commonsLogoMissTimeToLiveDays = 7;
  // Invalida lo guardado si cambia la regla de selección.
  static const String commonsLogoCacheKeyVersion = 'v1';
  static const String commonsLogoCacheKeyTag = 'brand-logo';
  static const String commonsLogoCacheKeySeparator = '|';
}
