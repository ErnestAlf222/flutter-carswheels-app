import 'dart:io';

import 'package:cars_wheels_app/core/config/user_agents_config.dart';

/// Parámetros de búsqueda de fotos.
class PhotosConfig {
  const PhotosConfig._();

  // Misma instancia constante para widgets: la caché de imágenes la usa en su llave.
  static const Map<String, String> requestHeaders = {
    HttpHeaders.userAgentHeader: UserAgentsConfig.commonsUserAgent,
  };

  static const int searchResultLimit = 20;
  static const int thumbnailWidthPixels = 600;
  // Ancho de la miniatura de lista; se verificó que Commons responde 200.
  static const int listThumbnailWidthPixels = 330;
  // Segmento de ancho dentro de la URL de miniatura y su plantilla.
  static const String thumbnailWidthSegmentPattern = r'/\d+px-';
  static const String thumbnailWidthSegmentFormat = '/{width}px-';
  static const String thumbnailWidthPlaceholder = '{width}';
  // Palabras que descartan un título de foto por no ser el auto completo.
  static const List<String> excludedTitleWords = [
    'Cross',
    'Mach-E',
    'Plug-in',
    'PHEV',
    'PHV',
    'Prime',
    'Interior',
    'Engine',
    'Badge',
    'Logo',
    'Police',
    'Patrol',
    'Taxi',
  ];

  static const String commonsSourceLabel = 'commons';
  static const Map<String, String> commonsRequestParameters = {
    'action': 'query',
    'generator': 'search',
    'gsrnamespace': '6',
    'prop': 'imageinfo',
    'iiprop': 'url|extmetadata',
    'format': 'json',
  };
  static const String searchTermParameter = 'gsrsearch';
  static const String searchLimitParameter = 'gsrlimit';
  static const String thumbnailWidthParameter = 'iiurlwidth';

  // Claves de la respuesta de Commons.
  static const String queryKey = 'query';
  static const String pagesKey = 'pages';
  static const String titleKey = 'title';
  static const String rankKey = 'index';
  static const String imageInfoKey = 'imageinfo';
  static const String thumbnailUrlKey = 'thumburl';
  static const String descriptionUrlKey = 'descriptionurl';
  static const String extMetadataKey = 'extmetadata';
  static const String artistKey = 'Artist';
  static const String licenseKey = 'LicenseShortName';
  static const String valueKey = 'value';
  static const String filePrefix = 'File:';

  // Siglas de tracción y puertas que se quitan del nombre del modelo.
  static const List<String> photoModelStripTokens = [
    '2WD',
    '4WD',
    'AWD',
    'FWD',
    'RWD',
    '2Dr',
    '4Dr',
    '5Dr',
  ];

  // Provisional: en una prueba real Commons pidió esperar 18 s.
  static const String retryAfterHeaderName = 'retry-after';
  static const int defaultRetryAfterSeconds = 20;
  static const int maxRetryAttempts = 2;

  // Limpieza del autor, que Commons entrega como HTML.
  static const String htmlTagPattern = '<[^>]*>';
  static const Map<String, String> htmlEntities = {
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&#39;': "'",
  };

  // Armado de los términos de búsqueda y coincidencia del año.
  static const String searchTermSeparator = ' ';
  static const String yearOpeningDelimiter = '(';
  static const String yearClosingDelimiter = ')';

  // Provisionales: diferencia máxima de años y vigencias de la caché.
  static const int maxReferenceYearDifference = 5;
  static const int photoCacheTimeToLiveDays = 30;
  static const int photoMissTimeToLiveDays = 3;
  static const String cacheKeySeparator = '|';

  // Rank de una página sin orden: queda al final de cualquier desempate.
  static const int missingRank = 1000000;
  static const int yearDigitCount = 4;

  // Separadores de palabras del título.
  static const String titleTokenPattern = r'[^\p{L}\p{N}]+';
  // Máximo de palabras entre el final de la marca y el inicio del modelo.
  static const int brandModelMaxWordGap = 4;
  // La clave del modelo puede ocupar de 1 a 3 palabras consecutivas.
  static const int modelKeyMaxTokenSpan = 3;
  // Lo que puede sobrar tras la clave dentro de una palabra: solo letras.
  static const String modelKeySuffixLettersPattern = r'^[a-z]+$';
  // Un año al inicio solo cuenta si va seguido de un espacio.
  static const String leadingYearPattern = r'^(\d{4})\s+';
  // Cualquier año de cuatro dígitos dentro de unos paréntesis.
  static const String parenthesizedYearPattern = r'\([^)]*?\b(\d{4})\b[^)]*\)';
  // Invalida las fotos guardadas con el selector anterior.
  static const String photoCacheKeyVersion = 'v2';

  // Tabla de excepciones que crece con los casos reales.
  static const Map<String, String> photoSearchTermAliases = {
    'f150': 'F-150',
    'f250': 'F-250',
    'f350': 'F-350',
  };
}
