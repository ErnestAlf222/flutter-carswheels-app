/// Medidas, tiempos y límites de la cuadrícula de modelos.
class ModelGridConfig {
  const ModelGridConfig._();

  // Cuadrícula.
  static const int columns = 2;
  static const double crossAxisSpacing = 14.0;
  static const double mainAxisSpacing = 14.0;
  // Proporción de la foto (ancho / alto); el alto de la celda sale del contenido.
  static const double photoAspectRatio = 1.3;
  // Relleno de la zona de texto.
  static const double textHorizontalPadding = 12.0;
  static const double textTopPadding = 10.0;
  static const double textBottomPadding = 12.0;
  static const int nameMaxLines = 2;
  static const double classTopGap = 2.0;
  static const double consumptionTopGap = 8.0;
  static const double consumptionChipHorizontalPadding = 10.0;
  static const double consumptionChipVerticalPadding = 5.0;
  // Espacio extra bajo la última fila, además de la barra flotante.
  static const double listBottomGap = 16.0;
  // Esqueleto de la cuadrícula; par para llenar las dos columnas.
  static const int skeletonCardCount = 4;
  static const double skeletonNameBarHeight = 14.0;
  static const double skeletonNameBarFraction = 0.8;
  static const double skeletonClassBarHeight = 12.0;
  static const double skeletonClassBarFraction = 0.5;
  static const double skeletonConsumptionBarWidth = 96.0;

  // Insignia de motorización sobre la foto.
  static const int maxEngineBadges = 3;
  static const double badgeInset = 8.0;
  static const double badgeSize = 28.0;
  static const double badgeIconSize = 18.0;
  static const double badgeGap = 4.0;
  // Salto de una sola vez: escala máxima sobre 1 y duración.
  static const double badgeBouncePeak = 0.25;
  static const int badgeBounceMilliseconds = 450;
}
