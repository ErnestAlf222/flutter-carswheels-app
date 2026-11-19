import 'package:flutter/painting.dart';

import 'package:cars_wheels_app/core/config/header_config.dart';
import 'package:cars_wheels_app/core/theme/app_colors.dart';

/// Degradados de la app: el resplandor del encabezado y la superposición de fotos.
class AppGradients {
  const AppGradients._();

  // Resplandor neutro del encabezado: de tinta suave en el centro a tinta.
  static const RadialGradient headerGlow = RadialGradient(
    colors: [AppColors.inkSoft, AppColors.ink],
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
