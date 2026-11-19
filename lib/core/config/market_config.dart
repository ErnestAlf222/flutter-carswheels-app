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

  // Selector de mercado y año: píldora tinta con bandera, año y chevron.
  static const double selectorHeight = 40.0;
  static const double selectorBorderWidth = 1.0;
  static const double selectorPadding = 4.0;
  static const double flagCircleSize = 32.0;
  static const double flagFontSize = 18.0;
  static const double yearZoneHorizontalPadding = 8.0;
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
