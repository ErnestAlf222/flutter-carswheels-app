/// Parámetros de búsqueda de fotos.
class PhotosConfig {
  const PhotosConfig._();

  static const int searchResultLimit = 20;
  static const int thumbnailWidthPixels = 600;
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
}
