import 'package:flutter/painting.dart';

import 'package:cars_wheels_app/core/config/header_config.dart';
import 'package:cars_wheels_app/core/theme/app_colors.dart';

/// Degradados de la app: la superposición de fotos y la veladura inferior.
class AppGradients {
  const AppGradients._();

  // Superposición de la foto de Detalle: transparente arriba, tinta abajo.
  static final LinearGradient photoOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.ink.withValues(alpha: HeaderConfig.photoOverlayTopOpacity),
      AppColors.ink.withValues(alpha: HeaderConfig.photoOverlayBottomOpacity),
    ],
  );

  // Veladura bajo la barra inferior de Detalle: del blanco transparente al sólido.
  static final LinearGradient detailBottomVeil = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.surface.withValues(alpha: 0), AppColors.surface],
  );
}
