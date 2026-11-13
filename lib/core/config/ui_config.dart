/// Medidas generales de interfaz.
class UiConfig {
  const UiConfig._();

  // Valor provisional.
  static const double loaderSize = 96.0;
  static const double iconSize = 24.0;
  static const double primaryButtonHeight = 60.0;
  static const double navClearance = 120.0;
  // Foto y relleno de la tarjeta de modelo.
  static const double modelPhotoWidth = 104.0;
  static const double modelPhotoHeight = 72.0;
  static const double modelCardLeftPadding = 8.0;
  static const double modelCardRightPadding = 20.0;
  static const double modelCardGap = 14.0;
  // Logo de marca en el recuadro de respaldo de la foto.
  static const double brandFallbackLogoSize = 40.0;
  // Insignia de foto de referencia.
  static const double referenceBadgeSize = 16.0;
  // Evita un parpadeo del loader; solo aplica a la carga inicial.
  static const int initialLoaderMinimumVisibleMilliseconds = 300;
  // Opacidad del contenido mientras se actualiza.
  static const double dimmedOpacity = 0.55;
  static const int skeletonCardCount = 3;
  static const double sectionLoaderSize = 120.0;
  // Barras del esqueleto de tarjeta: alto y ancho relativo al espacio libre.
  static const double skeletonBarHeight = 14.0;
  static const double skeletonLongBarFraction = 0.7;
  static const double skeletonShortBarFraction = 0.45;
  // Escala máxima del pulso del esqueleto.
  static const double skeletonPulseScale = 1.02;
  // Columna de consumo de la tarjeta de modelo y sus barras de esqueleto.
  static const double modelConsumptionColumnWidth = 84.0;
  static const double summarySkeletonBarHeight = 10.0;
  static const double summarySkeletonLongBarWidth = 56.0;
  static const double summarySkeletonShortBarWidth = 36.0;
  static const double powertrainBadgeIconSize = 14.0;
  // Alturas provisionales del encabezado fijo; se ajustan viendo la pantalla.
  static const double headerExpandedHeight = 188.0;
  static const double headerCompactHeight = 72.0;
  static const double headerCompactLogoSize = 40.0;
  // Medidas de la maqueta de Detalle.
  static const double detailHeroHeight = 280.0;
  static const double detailBlobCanvasWidth = 390.0;
  static const double detailBlobCanvasHeight = 320.0;
  static const double detailGhostTop = 84.0;
  static const double detailCircleButtonSize = 48.0;
  static const double detailCircleButtonInset = 20.0;
  static const double detailPhotoTop = 104.0;
  static const double detailPhotoHeight = 150.0;
  static const double detailPhotoSideMargin = 36.0;
  static const double detailPhotoBlurSigma = 18.0;
  static const double detailCreditGap = 4.0;
  static const double galleryDotSize = 6.0;
  static const double galleryDotSpacing = 6.0;
  static const double galleryDotsBottomInset = 8.0;
  static const double galleryDotsPadding = 6.0;
  static const double detailSelectorHeight = 56.0;
  static const double detailSelectorSideMargin = 20.0;
  static const double detailStatsSideMargin = 12.0;
  static const double detailInfoSideMargin = 24.0;
  static const double detailBottomBarHeight = 60.0;
  static const double detailBottomBarInset = 20.0;
  static const double detailBottomBarGap = 12.0;
  static const double detailBottomClearance = 100.0;
  static const double detailSheetMaxHeightFraction = 0.6;
  static const double detailSheetHandleWidth = 40.0;
  static const double detailSheetHandleHeight = 4.0;
  static const double detailGhostOpacity = 0.22;
  static const double detailChipVerticalPadding = 6.0;
  static const double detailChipHorizontalPadding = 14.0;
  static const double detailSelectorHorizontalPadding = 18.0;
  static const double detailStatDividerWidth = 1.0;
  static const double detailSkeletonChipWidth = 96.0;
  static const double detailSkeletonChipHeight = 28.0;
  static const double detailSkeletonStatsHeight = 96.0;
  static const double detailSkeletonRowHeight = 20.0;
  static const double detailStatsVerticalPadding = 14.0;
  static const double detailInfoRowVerticalPadding = 10.0;
  static const double detailRecallsTopMargin = 10.0;
  static const int detailSkeletonRowCount = 3;
  static const double dashedDashWidth = 4.0;
  static const double dashedGapWidth = 3.0;
  // Temporales: solo las usa la pantalla de relleno.
  static const int placeholderItemCount = 30;
  static const double placeholderItemHeight = 72.0;
}
