import 'package:flutter/painting.dart';

/// Paleta de colores de la app: negro tinta, amarillo señal y blanco.
class AppColors {
  const AppColors._();

  // Tinta y texto.
  static const Color ink = Color(0xFF0F1115);
  static const Color inkSoft = Color(0xFF1B1F27);
  static const Color mutedText = Color(0xFF5F6673);
  static const Color mutedOnDark = Color(0xB3FFFFFF);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color backgroundClear = Color(0x00FFFFFF);
  // Amarillo: relleno con tinta encima, o texto e ícono solo sobre oscuro.
  static const Color accent = Color(0xFFFFD60A);
  static const Color accentPressed = Color(0xFFF2C800);
  static const Color accentTint = Color(0xFFFFF6C2);
  // Selector de Comparar: banda gris azulada propia, distinta de la tinta de Buscar.
  static const Color pickerBand = Color(0xFF2B3544);
  static const Color pickerBandField = Color(0xFF3A4658);
  static const Color pickerBandFieldBorder = Color(0xFF4C586C);
  // Superficies.
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFFE7E5DE);
  static const Color photoPlaceholder = Color(0xFFECEAE3);
  static const Color chipBackground = Color(0xFFF1EEE6);
  static const Color dashedLine = Color(0xFFD3CCBB);
  static const Color shadow = Color(0x140F1115);
  static const Color navShadow = Color(0x590F1115);
  // Barra inferior: ícono inactivo.
  static const Color navInactive = Color(0xA6FFFFFF);
  // Fotos: puntos del carrusel, cápsulas y botones sobre la foto.
  static const Color galleryDotInactive = Color(0x80FFFFFF);
  static const Color galleryDotActive = accent;
  static const Color galleryDotsBackground = Color(0x660F1115);
  static const Color photoChipBackground = Color(0x8C0F1115);
  static const Color circleButtonOnPhoto = Color(0x990F1115);
  static const Color photoViewerBackground = Color(0xFF0E0E12);
  static const Color photoViewerCreditText = Color(0xD9FFFFFF);
  // Gráfica neón sobre tinta: trazo, halo, brillo atenuado y línea base.
  static const Color chartNeon = Color(0xFFFFD60A);
  static const Color chartNeonGlow = Color(0x99FFD60A);
  static const Color chartNeonDim = Color(0x8CFFD60A);
  static const Color chartNeonDimGlow = Color(0x40FFD60A);
  static const Color chartAxis = Color(0x40FFFFFF);
  // Relleno de área bajo la línea ondeada: sutil arriba y transparente en la base.
  static const Color chartNeonArea = Color(0x38FFD60A);
  static const Color chartNeonAreaFade = Color(0x00FFD60A);
  // Insignias de motorización y chips de la tarjeta de modelo.
  static const Color engineElectric = Color(0xFF16A34A);
  static const Color enginePluginHybrid = Color(0xFF0D9488);
  static const Color engineHybrid = Color(0xFF65A30D);
  static const Color engineHydrogen = Color(0xFF2563EB);
  static const Color engineDiesel = Color(0xFFD97706);
  static const Color engineFuel = mutedText;
  static const Color engineBadgeBackground = Color(0xF2FFFFFF);
  // Acentos de las banderas (solo colores, sin escudos) para el águila.
  static const Color flagMexicoGreen = Color(0xFF006847);
  static const Color flagMexicoWhite = Color(0xFFFFFFFF);
  static const Color flagMexicoRed = Color(0xFFCE1126);
  static const Color flagUsRed = Color(0xFFB22234);
  static const Color flagUsWhite = Color(0xFFFFFFFF);
  static const Color flagUsBlue = Color(0xFF3C3B6E);
  // Águila real (México): cuerpo café oscuro, plumas y nuca doradas.
  static const Color eagleGoldenBody = Color(0xFF4A2E17);
  static const Color eagleGoldenLight = Color(0xFFC9953C);
  static const Color eagleGoldenCrown = Color(0xFFE2B45E);
  // Águila calva (EE. UU.): cuerpo oscuro, cabeza y cola blancas.
  static const Color eagleBaldBody = Color(0xFF2B1D14);
  static const Color eagleBaldLight = Color(0xFF4A3526);
  static const Color eagleBaldWhite = Color(0xFFFFFFFF);
  static const Color eagleBeak = Color(0xFFF2B705);
  // Ojo y contorno de ambas águilas.
  static const Color eagleOutline = Color(0xFF1A110A);
}
