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
}
