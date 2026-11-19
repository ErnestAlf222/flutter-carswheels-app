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

  // Interruptor de mercado: píldora tinta con las dos banderas y un disco amarillo.
  static const double selectorHeight = 44.0;
  static const double selectorBorderWidth = 1.0;
  static const double flagTouchSize = 44.0; // Área táctil mínima por bandera.
  static const double flagDiscSize = 34.0;
  static const double flagFontSize = 18.0;
  static const double inactiveFlagOpacity = 0.45;
  static const double selectorGap =
      8.0; // En fila (barra compacta): entre interruptor y píldora de año.
  static const double stackedGap = 8.0; // Apilado: entre interruptor y año.
  static const double stackedHeight = selectorHeight * 2 + stackedGap;

  // Píldora de año: solo borde fino, con el año y el chevron.
  static const double yearZoneHorizontalPadding = 14.0;
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
