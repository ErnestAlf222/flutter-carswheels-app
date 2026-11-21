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

  /// Bandera de un mercado por su código; EE. UU. si no se reconoce.
  static String flagOf(String code) =>
      code == mexicoCode ? mexicoFlag : unitedStatesFlag;

  // Orden fijo de las banderas del interruptor (códigos de mercado).
  static const List<String> switchOrderCodes = [mexicoCode, unitedStatesCode];

  // Píldora unida: banderas, raya vertical y año en una sola fila tinta.
  static const double selectorBorderWidth = 1.0;
  // Borde blanco de baja opacidad de la píldora sobre el encabezado tinta.
  static const double selectorBorderOnDarkOpacity = 0.28;
  static const double flagTouchSize = 44.0; // Área táctil mínima por opción.
  static const double selectorHeight = flagTouchSize + 2 * selectorBorderWidth;
  static const double selectorInnerPadding =
      2.0; // Entre el borde y el contenido.
  // Insignia circular de la bandera: tamaño visible, glifo y borde finísimo.
  static const double flagBadgeSize = 24.0;
  static const double flagFontSize = 31.0;
  static const double flagBadgeBorderWidth = 0.5;
  static const double flagBadgeBorderOpacity = 0.35;
  // Opción del control segmentado: relleno, hueco entre bandera y código.
  static const double optionHorizontalPadding = 6.0;
  static const double optionFlagGap = 4.0;
  // Pastilla deslizante: margen respecto de la opción.
  static const double pillInsetVertical = 4.0;
  static const double pillInsetHorizontal = 2.0;
  // Texto inactivo: atenuado pero con contraste AA sobre tinta.
  static const double inactiveCodeOnDarkOpacity = 0.72;
  // El código no crece con la escala de texto: el selector compacto debe caber a 360 dp.
  static const double codeMaxTextScale = 1.0;
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

  // Aviso estático (menos movimiento): duración, bandera y medidas.
  static const int noticeDurationMilliseconds = 3000;
  static const double noticeFlagSize = 28.0;
  static const double noticeGap = 12.0;
  static const double noticeRadius = 20.0;
  static const double noticeHorizontalPadding = 16.0;
  static const double noticeVerticalPadding = 12.0;
  static const double noticeSideMargin = 16.0;
  static const double noticeBottomGap = 12.0;
  static const double noticeFlagRingWidth = 1.5;

  // Celebración del cambio de mercado: tarjeta, bandera y ondulación.
  static const double celebrationCardWidth = 280.0;
  static const double celebrationCardRadius = 28.0;
  static const double celebrationCardPadding = 20.0;
  // Posición vertical de la tarjeta (de -1 arriba a 1 abajo).
  static const double celebrationVerticalAlignment = -0.25;
  static const double celebrationFlagWidth = 168.0;
  static const double celebrationFlagHeight = 112.0;
  // Margen alrededor de la bandera para que la onda no se recorte.
  static const double celebrationFlagWavePadding = 10.0;
  static const double celebrationFlagGap = 14.0;
  static const double flagOutlineWidth = 2.0;
  static const int flagWaveSlices = 28;
  static const double flagWaveAmplitude = 7.0;
  static const double flagWaveCount = 1.6;
  // Vueltas de la onda durante la celebración y sombreado de las crestas.
  static const double flagWaveTurns = 2.0;
  static const double flagWaveShadeOpacity = 0.16;
  // Fracciones de la duración: fin de la entrada e inicio de la salida.
  static const double celebrationEnterEnd = 0.22;
  static const double celebrationExitStart = 0.8;
  static const double celebrationStartScale = 0.86;
  static const double celebrationEndScale = 0.96;
  // Destellos: duración relativa de cada uno y grosor del contorno.
  static const double sparkleLifeFraction = 0.4;
  static const double sparkleOutlineWidth = 1.2;
  // Cada destello: x, y (-1..1 sobre la tarjeta), tamaño, inicio (0..1) y si es amarillo.
  static const List<(double, double, double, double, bool)> sparkles = [
    (-0.86, -0.78, 16.0, 0.05, true),
    (0.84, -0.7, 12.0, 0.15, false),
    (-0.92, -0.1, 10.0, 0.3, false),
    (0.9, 0.05, 18.0, 0.1, true),
    (-0.7, 0.5, 14.0, 0.25, true),
    (0.72, 0.62, 10.0, 0.35, false),
    (0.0, -0.98, 10.0, 0.2, false),
    (-0.3, -0.92, 12.0, 0.4, true),
    (0.4, -0.95, 14.0, 0.45, true),
  ];

  // Bandera estilizada: proporciones de EE. UU. (sin escudos ni águilas en México).
  static const int usStripeCount = 13;
  static const double usCantonWidthFraction = 0.4;
  static const int usCantonStripes = 7;
  static const int usStarRows = 9;
  static const int usStarColumns = 6;
  static const double usStarRadiusFraction = 0.4;
}
