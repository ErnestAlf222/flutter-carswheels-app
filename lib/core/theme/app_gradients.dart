import 'package:flutter/painting.dart';

import 'package:cars_wheels_app/core/config/header_config.dart';
import 'package:cars_wheels_app/core/theme/app_colors.dart';

/// Degradados de la app: el resplandor del encabezado y la superposición de fotos.
class AppGradients {
  const AppGradients._();

  // Resplandor amarillo del encabezado: del centro (opacidad de config) a nada.
  static final RadialGradient headerGlow = RadialGradient(
    colors: [
      AppColors.accent.withValues(alpha: HeaderConfig.glowOpacity),
      AppColors.accent.withValues(alpha: 0),
    ],
  );

  // Superposición de la foto de Detalle: transparente arriba, tinta abajo.
  static final LinearGradient photoOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.ink.withValues(alpha: HeaderConfig.photoOverlayTopOpacity),
      AppColors.ink.withValues(alpha: HeaderConfig.photoOverlayBottomOpacity),
    ],
  );
}
