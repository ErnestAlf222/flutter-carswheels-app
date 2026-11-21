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
  static const int yearNoticeDurationMilliseconds = 3200;
  static const double yearNoticeIconSize = 18.0;
  static const double noticeFlagSize = 28.0;
  static const double noticeGap = 12.0;
  static const double noticeRadius = 20.0;
  static const double noticeHorizontalPadding = 16.0;
  static const double noticeVerticalPadding = 12.0;
  static const double noticeSideMargin = 16.0;
  static const double noticeBottomGap = 12.0;
  static const double noticeFlagRingWidth = 1.5;

  // Celebración del cambio de mercado: águila en vuelo y píldora de texto.
  // Envergadura máxima del águila: fracción del ancho de pantalla y tope en dp.
  static const double eagleSpanScreenFraction = 0.82;
  static const double eagleMaxSpan = 340.0;
  // Fracciones de la duración: fin del acercamiento y fin del giro frente a la persona.
  static const double eagleApproachEnd = 0.46;
  static const double eagleTurnEnd = 0.64;
  // Puntos del vuelo como fracción de la pantalla: lejos, frente a la persona y salida.
  static const (double, double) eagleFarPoint = (0.5, 0.27);
  static const (double, double) eagleNearPoint = (0.5, 0.4);
  static const (double, double) eagleExitPoint = (1.2, 0.12);
  // Tamaño relativo (1 = envergadura completa) al salir de lejos y al alejarse.
  static const double eagleFarScale = 0.1;
  static const double eagleExitScale = 0.08;
  // Aleteos completos durante todo el vuelo y vaivén vertical en dp.
  static const double eagleFlapCycles = 3.5;
  static const double eagleBobAmplitude = 10.0;
  // Giro: inclinación final (rad) y ángulo con que se estrecha el ancho de frente.
  static const double eagleRoll = -0.45;
  static const double eagleTurnAngle = 0.9;
  // Se desvanece desde esta fracción del vuelo.
  static const double eagleFadeStart = 0.9;
  // Estela de destellos: cuántos, desfase, tamaño relativo a la envergadura y dispersión.
  static const int trailSparkleCount = 8;
  static const double trailSparkleLag = 0.018;
  static const double trailSparkleSize = 0.07;
  static const double trailSparkleSpread = 0.16;
  static const double trailSparkleOutlineWidth = 1.2;
  // Píldora: posición vertical (de -1 arriba a 1 abajo), márgenes, desplazamiento y tiempos.
  static const double pillVerticalAlignment = 0.5;
  static const double pillSideMargin = 24.0;
  static const double pillMaxWidth = 320.0;
  static const double pillSlideOffset = 14.0;
  static const double pillEnterStart = 0.34;
  static const double pillEnterEnd = 0.5;
  static const double pillExitStart = 0.84;
  static const double pillExitEnd = 0.97;
  // Opacidad desde la que la píldora recibe toques.
  static const double pillTouchableFrom = 0.2;
}

/// Geometría del águila en vuelo, en coordenadas unitarias.
///
/// El origen es el centro del cuerpo, media envergadura vale 1 en x y la y
/// crece hacia abajo. Solo se define el ala derecha; la izquierda es su espejo.
class EagleArtConfig {
  const EagleArtConfig._();

  // Ángulos del ala (rad) en la pose arriba y en la pose abajo; el aleteo los interpola.
  static const double wingUpAngle = -0.8;
  static const double wingDownAngle = 0.2;
  // El ala gira alrededor del hombro y más cuanto más lejos de él.
  static const (double, double) wingPivot = (0.1, -0.08);
  static const double wingBendReach = 0.9;
  static const double wingBendCurve = 1.25;

  // Borde de ataque: hombro y dos curvas hasta la punta.
  static const (double, double) wingShoulder = (0.1, -0.12);
  static const List<((double, double), (double, double), (double, double))>
  wingLeadingCurves = [
    ((0.2, -0.26), (0.36, -0.38), (0.52, -0.34)),
    ((0.68, -0.32), (0.9, -0.24), (1.0, -0.1)),
  ];
  // Plumas primarias: punta y muesca alternadas hacia el cuerpo.
  static const List<(double, double)> wingFeatherPoints = [
    (0.99, 0.14),
    (0.92, 0.04),
    (0.92, 0.28),
    (0.83, 0.14),
    (0.78, 0.4),
    (0.69, 0.22),
    (0.6, 0.46),
    (0.5, 0.28),
  ];
  // Borde de salida hasta el cuerpo: control y destino; luego la raíz.
  static const ((double, double), (double, double)) wingTrailingCurve = (
    (0.34, 0.36),
    (0.16, 0.26),
  );
  static const (double, double) wingRoot = (0.12, 0.1);

  // Franjas de colores sobre el ala: alturas, grosor y tramo en x.
  static const List<double> accentBandOffsets = [0.0, 0.085, 0.17];
  static const double accentBandWidth = 0.085;
  static const double accentBandStartX = 0.1;
  static const double accentBandEndX = 1.05;
  static const int accentBandSegments = 8;
  // Cobertoras claras del ala: altura y grosor de la franja.
  static const double wingPatchY = -0.2;
  static const double wingPatchWidth = 0.17;

  // Cola en abanico.
  static const List<(double, double)> tailPoints = [
    (-0.12, 0.3),
    (-0.23, 0.68),
    (-0.075, 0.68),
    (0.0, 0.76),
    (0.075, 0.68),
    (0.23, 0.68),
    (0.12, 0.3),
  ];

  // Torso: cuello izquierdo, curvas de cada lado y base.
  static const (double, double) torsoNeckLeft = (-0.1, -0.28);
  static const ((double, double), (double, double), (double, double))
  torsoLeftCurve = ((-0.22, -0.1), (-0.22, 0.12), (-0.12, 0.36));
  static const (double, double) torsoBaseRight = (0.12, 0.36);
  static const ((double, double), (double, double), (double, double))
  torsoRightCurve = ((0.22, 0.12), (0.22, -0.1), (0.1, -0.28));
  // Arcos del pecho: centro x, centro y, ancho y alto.
  static const List<(double, double, double, double)> chestArcs = [
    (0.0, -0.08, 0.17, 0.1),
    (0.0, 0.04, 0.2, 0.11),
    (0.0, 0.16, 0.19, 0.11),
  ];

  // Cabeza de perfil mirando a la derecha: centro, radio, pico y ojo.
  static const (double, double) headCenter = (0.0, -0.38);
  static const double headRadius = 0.125;
  static const (double, double) beakStart = (0.07, -0.43);
  static const ((double, double), (double, double), (double, double))
  beakTopCurve = ((0.17, -0.46), (0.27, -0.42), (0.29, -0.31));
  static const ((double, double), (double, double), (double, double))
  beakBottomCurve = ((0.24, -0.34), (0.2, -0.32), (0.16, -0.29));
  static const (double, double) beakEnd = (0.07, -0.33);
  static const (double, double) eyeCenter = (0.045, -0.405);
  static const double eyeRadius = 0.024;
  static const (double, double) browStart = (-0.01, -0.445);
  static const (double, double) browEnd = (0.085, -0.415);
  static const double browWidth = 0.022;

  // Contorno de todas las piezas, en unidades.
  static const double outlineWidth = 0.018;
}
