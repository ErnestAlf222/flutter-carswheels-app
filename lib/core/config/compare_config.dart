/// Límites, persistencia y medidas del comparador de vehículos.
class CompareConfig {
  const CompareConfig._();

  // Cuántos vehículos caben y cuántos hacen falta para comparar.
  static const int maxSlots = 3;
  static const int minSlots = 2;

  // Claves de Isar versionadas: subir la versión invalida lo guardado.
  static const String storageKeyPrefix = 'compare';
  static const String storageKeyVersion = 'v1';
  static const String storageKeySeparator = '|';

  // Campos del JSON guardado por cada vehículo.
  static const String payloadSlotsKey = 'slots';
  static const String payloadMarketKey = 'market';
  static const String payloadYearKey = 'year';
  static const String payloadBrandKey = 'brand';
  static const String payloadGroupKey = 'group';
  static const String payloadModelKey = 'model';
  static const String payloadVersionKey = 'version';

  // Separador de las partes de la identidad de un vehículo.
  static const String identitySeparator = '|';

  // Cuánto dura el mensaje breve de "ya está" o "lleno".
  static const int noticeDurationMilliseconds = 3500;

  // Espacios de la fila: separación, alto mínimo, esquinas, borde y contenido.
  static const double slotGap = 8.0;
  static const double slotMinHeight = 188.0;
  static const double slotRadius = 20.0;
  static const double slotBorderWidth = 1.5;
  static const double slotTextPadding = 8.0;
  static const double slotLogoSize = 16.0;
  static const double slotLogoGap = 4.0;
  static const int slotNameMaxLines = 2;
  static const double slotPlusSize = 32.0;
  static const double slotPlusLabelGap = 6.0;
  static const double slotPhotoAspectRatio = 1.35;

  // Botón de quitar sobre la foto.
  static const double removeButtonSize = 28.0;
  static const double removeButtonIconSize = 16.0;
  static const double removeButtonInset = 6.0;
  static const double removeButtonOpacity = 0.6;
  static const double removeTouchSize = 44.0;

  // Borde punteado: largo del trazo, del hueco y de los arcos de las esquinas.
  static const double dashLength = 7.0;
  static const double dashGap = 5.0;

  // Textos de ayuda.
  static const double helpTopGap = 20.0;
  static const double helpButtonGap = 20.0;

  // Pastilla de versión bajo cada espacio ocupado.
  static const double versionPillTopGap = 8.0;
  static const double versionPillHorizontalPadding = 8.0;
  static const double versionPillVerticalPadding = 6.0;
  static const double versionPillIconSize = 16.0;
  static const double versionPillIconGap = 2.0;
  static const int versionPillMaxLines = 2;

  // Tabla: título, banda fija de columnas, secciones y filas.
  static const double tableTopGap = 28.0;
  static const double tableSupportGap = 4.0;
  static const double tableBandTopGap = 8.0;
  static const double bandVerticalPadding = 8.0;
  static const double bandBorderWidth = 1.0;
  static const double sectionTopGap = 24.0;
  static const double sectionTitleGap = 8.0;
  static const double rowGap = 14.0;
  static const double rowLabelGap = 4.0;

  // Pastilla de versión rediseñada: overline, círculo del chevron y estado abierto.
  static const double versionPillCircleSize = 20.0;
  static const double versionPillOpenBorderWidth = 1.5;
  static const double versionPillChevronSize = 14.0;
  static const double versionPillOverlineGap = 1.0;

  // Hoja de versiones: asa, filas y marca de la elegida.
  static const double versionRowMinHeight = 56.0;
  static const double versionCheckSize = 24.0;
  static const double versionCheckIconSize = 16.0;

  // Hoja de comparador lleno y de ayuda.
  static const double fullRowPhotoWidth = 64.0;
  static const double fullRowPhotoHeight = 44.0;
  static const double fullRowPhotoRadius = 10.0;
  static const double fullRowGap = 12.0;
  static const double helpStepCircleSize = 28.0;
  static const double helpStepGap = 12.0;
  static const double helpButtonIconSize = 20.0;

  // Selector de vehículo como hoja inferior sobre Comparar.
  static const double pickerSheetHeightFraction = 0.92;

  // Botón flotante de la gráfica: igual huella que los de Buscar.
  static const double chartButtonSize = 52.0;
  static const double chartButtonIconSize = 26.0;

  // Hoja oscura de la gráfica neón.
  static const double chartSheetMaxHeightFraction = 0.8;
  static const double chartRowGap = 22.0;
  static const double chartLabelBarGap = 8.0;
  static const double chartBarHeight = 14.0;
  static const double chartAxisWidth = 1.0;
  static const double chartSegmentHeight = 36.0;
  static const double chartSegmentGap = 8.0;
  static const double chartSegmentHorizontalPadding = 14.0;
  static const double chartValueGap = 12.0;

  // Halo neón: dos capas de desenfoque, la ancha y la cercana.
  static const double chartGlowOuterSigma = 14.0;
  static const double chartGlowInnerSigma = 5.0;
  static const double chartGlowSpread = 2.0;

  // Crecimiento de las barras al abrir y al cambiar de métrica.
  static const int chartGrowMilliseconds = 520;

  // Pastilla del mejor valor.
  static const double bestPillHorizontalPadding = 8.0;
  static const double bestPillVerticalPadding = 2.0;
  static const double bestPillRadius = 8.0;

  // Carga y error de una columna.
  static const double statusMinHeight = 56.0;
  static const double statusTopGap = 12.0;
  static const double statusMessageGap = 4.0;

  // Hoja de versiones.
  static const double sheetStatusPadding = 24.0;

  // Mensaje breve bajo el encabezado.
  static const double noticeVerticalPadding = 10.0;
  static const double noticeHorizontalPadding = 14.0;
  static const double noticeIconSize = 18.0;
  static const double noticeIconGap = 8.0;

  // Estado vacío.
  static const double emptyIconSize = 28.0;
  static const double emptyIconDisc = 56.0;
}
