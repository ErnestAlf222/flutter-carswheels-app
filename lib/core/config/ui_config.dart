/// Medidas generales de interfaz.
class UiConfig {
  const UiConfig._();

  // Valor provisional.
  static const double loaderSize = 96.0;
  static const double iconSize = 24.0;
  static const double primaryButtonHeight = 60.0;
  static const double navClearance = 120.0;
  static const double modelThumbnailSize = 56.0;
  // Evita un parpadeo del loader; solo aplica a la carga inicial.
  static const int initialLoaderMinimumVisibleMilliseconds = 300;
  // Opacidad del contenido mientras se actualiza.
  static const double dimmedOpacity = 0.55;
  static const int skeletonCardCount = 3;
  static const double sectionLoaderSize = 72.0;
  // Barras del esqueleto de tarjeta: alto y ancho relativo al espacio libre.
  static const double skeletonBarHeight = 14.0;
  static const double skeletonLongBarFraction = 0.7;
  static const double skeletonShortBarFraction = 0.45;
  // Escala máxima del pulso del esqueleto.
  static const double skeletonPulseScale = 1.02;
  // Temporales: solo las usa la pantalla de relleno.
  static const int placeholderItemCount = 30;
  static const double placeholderItemHeight = 72.0;
}
