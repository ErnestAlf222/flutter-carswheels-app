/// Persistencia, mensajes y medidas de los favoritos.
class FavoritesConfig {
  const FavoritesConfig._();

  // Claves de Isar versionadas: subir la versión invalida lo guardado.
  static const String storageKeyPrefix = 'favorite';
  static const String storageKeyVersion = 'v1';
  static const String storageKeySeparator = '|';

  // Separador de las partes de la identidad de un favorito.
  static const String identitySeparator = '|';

  // Campos del JSON guardado por cada favorito.
  static const String payloadMarketKey = 'market';
  static const String payloadYearKey = 'year';
  static const String payloadBrandKey = 'brand';
  static const String payloadGroupKey = 'group';
  static const String payloadModelKey = 'model';
  static const String payloadSavedAtKey = 'savedAt';
  static const String payloadLabelKey = 'label';
  static const String payloadEngineKindsKey = 'engineKinds';
  static const String payloadMinKmKey = 'minKm';
  static const String payloadMaxKmKey = 'maxKm';
  static const String payloadVariantsKey = 'variants';
  static const String payloadPhotoKey = 'photo';
  static const String payloadPhotoUrlKey = 'url';
  static const String payloadPhotoAuthorKey = 'author';
  static const String payloadPhotoLicenseKey = 'license';
  static const String payloadPhotoSourceKey = 'source';
  static const String payloadPhotoReferenceKey = 'reference';
  static const String payloadPhotoAspectKey = 'aspect';
  // Ancho y alto en píxeles de la foto; ausentes en lo guardado antes de existir.
  static const String payloadPhotoWidthKey = 'width';
  static const String payloadPhotoHeightKey = 'height';
  // Nombre del archivo local de la foto; ausente en lo guardado antes de existir.
  static const String payloadPhotoLocalKey = 'local';

  // Mensajes breves: el normal y el que lleva "Deshacer".
  static const int messageDurationMilliseconds = 2500;
  static const int undoDurationMilliseconds = 5000;
  static const int messageEnterMilliseconds = 220;
  static const double messageOffset = 0.4;
  static const double messageBottomGap = 12.0;
  static const double messageHorizontalPadding = 16.0;
  static const double messageVerticalPadding = 6.0;
  static const double messageIconSize = 18.0;
  static const double messageIconGap = 8.0;
  static const double messageActionTouchHeight = 44.0;

  // Corazón de las tarjetas: área táctil, círculo, ícono y margen.
  static const double heartTouchSize = 44.0;
  static const double heartCircleSize = 32.0;
  static const double heartIconSize = 18.0;
  static const int heartPopMilliseconds = 260;
  static const double heartPopPeak = 0.28;

  // Insignia de mercado y año sobre la foto de la tarjeta de Favoritos.
  static const double marketBadgeInset = 8.0;
  static const double marketBadgeHorizontalPadding = 8.0;
  static const double marketBadgeVerticalPadding = 3.0;

  // Filtro de texto segmentado "Todos · EE. UU. · México".
  static const double filterHeight = 44.0;
  static const double filterGap = 20.0;
  static const double filterUnderlineHeight = 3.0;
  static const double filterUnderlineGap = 4.0;

  // Encabezado y lista.
  static const double headerSubtitleGap = 2.0;
  static const double listTopGap = 20.0;
  static const double filterBottomGap = 12.0;

  // Mosaico de dos columnas: proporción de la foto (ancho / alto) por defecto y límites.
  static const double mosaicDefaultPhotoAspect = 1.3;
  static const double mosaicMinPhotoAspect = 0.75;
  static const double mosaicMaxPhotoAspect = 1.5;
  // Atenuación de una tarjeta que no se puede elegir en el modo de selección.
  static const double selectionDimmedOpacity = 0.4;

  // Modo de selección: casilla circular sobre la foto y barra inferior.
  static const double checkboxTouchSize = 44.0;
  static const double checkboxSize = 24.0;
  static const double checkboxIconSize = 16.0;
  static const double checkboxBorderWidth = 2.0;
  static const double selectionBarHorizontalPadding = 16.0;
  static const double selectionBarVerticalPadding = 10.0;
  static const double selectionBarGap = 12.0;
  static const double selectionBarNoteGap = 6.0;
  static const double selectionBarRadius = 20.0;
  static const double selectionActionIconSize = 20.0;
  // Espacio extra al final de la lista mientras la barra de selección está a la vista.
  static const double selectionListReserve = 116.0;

  // Estado vacío: ilustración dibujada y espacios.
  static const double emptyIllustrationSize = 168.0;
  static const double emptyStrokeWidth = 2.0;
  static const double emptyTopGap = 56.0;
  static const double emptyTitleGap = 20.0;
  static const double emptyBodyGap = 8.0;
  static const double emptyButtonGap = 28.0;
  static const double emptyButtonMaxWidth = 280.0;

  // Ráfaga de corazoncitos al activar un favorito: partículas fijas por semilla.
  static const int burstMilliseconds = 700;
  static const int burstParticleCount = 7;
  static const int burstSeed = 12;
  static const double burstRiseDistance = 64.0;
  static const double burstSpread = 34.0;
  static const double burstMinSize = 9.0;
  static const double burstMaxSize = 16.0;
  static const double burstOutlineWidth = 1.2;
  static const double burstFadeStart = 0.55;
  static const double burstBoxSize = 120.0;

  // Fotos de favoritos en disco: carpeta propia, nombre derivado de la identidad.
  static const String photosDirectoryName = 'favorite_photos';
  static const String photoFileExtension = '.jpg';
  static const String photoTempExtension = '.part';
  static const String photoNameSeparator = '_';
  static const int photoSlugMaxLength = 24;
  // Calidad: ancho de la miniatura; Commons solo sirve anchos estándar (960 sí, 800 da 400).
  static const int photoWidthPixels = 960;
  // Provisional: una miniatura de 960 px pesa unos 150 KB.
  static const int photoMaxBytes = 1048576;
  static const int photoDownloadTimeoutSeconds = 20;
  // Limpieza de archivos huérfanos al iniciar; los recientes no se tocan.
  static const bool cleanOrphansOnStart = true;
  static const int orphanGraceMinutes = 10;
}
