import 'package:flutter/painting.dart';

/// Paleta de colores de la app: negro tinta, amarillo señal y blanco.
class AppColors {
  const AppColors._();

  // Tinta y texto.
  static const Color ink = Color(0xFF0F1115);
  static const Color inkSoft = Color(0xFF1B1F27);
  static const Color mutedText = Color(0xFF5F6673);
  static const Color mutedOnDark = Color(0xB3FFFFFF);
  // Píldora translúcida sobre el encabezado oscuro.
  static const Color onDarkPill = Color(0x29FFFFFF);
  static const Color onDark = Color(0xFFFFFFFF);
  // Amarillo: relleno con tinta encima, o texto e ícono solo sobre oscuro.
  static const Color accent = Color(0xFFFFD60A);
  static const Color accentPressed = Color(0xFFF2C800);
  static const Color accentTint = Color(0xFFFFF6C2);
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
  // Insignias de motorización y chips de la tarjeta de modelo.
  static const Color engineElectric = Color(0xFF16A34A);
  static const Color enginePluginHybrid = Color(0xFF0D9488);
  static const Color engineHybrid = Color(0xFF65A30D);
  static const Color engineHydrogen = Color(0xFF2563EB);
  static const Color engineDiesel = Color(0xFFD97706);
  static const Color engineFuel = mutedText;
  static const Color engineBadgeBackground = Color(0xF2FFFFFF);
}
