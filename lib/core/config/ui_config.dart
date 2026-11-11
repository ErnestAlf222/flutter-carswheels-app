/// Medidas generales de interfaz.
class UiConfig {
  const UiConfig._();

  // Valor provisional.
  static const double loaderSize = 96.0;
  static const double iconSize = 24.0;
  static const double primaryButtonHeight = 60.0;
  static const double navClearance = 120.0;
  static const double modelThumbnailSize = 56.0;
  // Provisional: evita un parpadeo del loader si la carga es muy rápida.
  static const int loaderMinimumVisibleMilliseconds = 500;
  // Temporales: solo las usa la pantalla de relleno.
  static const int placeholderItemCount = 30;
  static const double placeholderItemHeight = 72.0;
}
