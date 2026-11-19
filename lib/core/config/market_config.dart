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

  // Selector segmentado del encabezado.
  static const double selectorHeight = 36.0;
  static const double selectorSegmentMinWidth = 64.0;
  static const double selectorSegmentHorizontalPadding = 12.0;
  static const double selectorPadding = 3.0;
}
