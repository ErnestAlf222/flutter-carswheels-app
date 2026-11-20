/// Mercados del catálogo, su persistencia y las medidas del selector.
class MarketConfig {
  const MarketConfig._();

  // Códigos guardados en disco; no cambiarlos sin migrar lo guardado.
  static const String unitedStatesCode = 'us';
  static const String mexicoCode = 'mx';

  // Mercado con el que arranca la app la primera vez.
  static const String defaultMarketCode = unitedStatesCode;

  // Única fila de preferencia en Isar.
  static const int preferenceRecordId = 1;

  // Separador de la parte del mercado en las claves de resumen.
  static const String keyScopeSeparator = '|';

  // Emoji de bandera de cada mercado.
  static const String unitedStatesFlag = '\u{1F1FA}\u{1F1F8}';
  static const String mexicoFlag = '\u{1F1F2}\u{1F1FD}';

  // Orden fijo de las banderas del interruptor (códigos de mercado).
  static const List<String> switchOrderCodes = [mexicoCode, unitedStatesCode];

  // Píldora unida: banderas, raya vertical y año en una sola fila tinta.
  static const double selectorBorderWidth = 1.0;
  // Borde blanco de baja opacidad de la píldora sobre el encabezado tinta.
  static const double selectorBorderOnDarkOpacity = 0.28;
  static const double flagTouchSize = 44.0; // Área táctil mínima por bandera.
  static const double selectorHeight = flagTouchSize + 2 * selectorBorderWidth;
  static const double selectorInnerPadding =
      2.0; // Entre el borde y el contenido.
  static const double flagGap = 4.0; // Hueco entre las dos banderas.
  // Aro fino de la bandera activa, sin relleno.
  static const double flagRingSize = 32.0;
  static const double flagRingWidth = 1.5;
  // Insignia circular de la bandera: tamaño visible, glifo y borde finísimo.
  static const double flagBadgeSize = 22.0;
  static const double flagFontSize = 28.0;
  static const double flagBadgeBorderWidth = 0.5;
  static const double flagBadgeBorderOpacity = 0.35;
  // La bandera inactiva sigue a color: opacidad suave, nunca menor a 0.7.
  static const double inactiveFlagOpacity = 0.75;
  static const double dividerGap = 6.0; // A cada lado de la raya.
  static const double dividerWidth = 1.0;
  static const double dividerHeight = 22.0;
  static const double dividerOpacity = 0.28;

  // Segmento del año: año y chevron, con área táctil mínima.
  static const double yearTouchMinWidth = 44.0;
  static const double yearZoneHorizontalPadding = 10.0;
  static const double chevronSize = 18.0;

  // Panel de años anclado bajo el selector.
  static const double yearPanelGap = 6.0;
  static const double yearPanelWidth = 104.0;
  static const double yearPanelMaxHeight = 220.0;
  static const double yearPanelItemHeight = 44.0;
  static const double yearPanelVerticalPadding = 6.0;
  static const double yearPanelItemRadius = 12.0;
  static const double yearPanelScaleBegin = 0.92;
}
