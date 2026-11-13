import 'package:flutter/painting.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/app_colors.dart';

/// Formas vectoriales de la app.
class AppShapes {
  const AppShapes._();

  static const double _blobGradientOpacity = 0.3;
  static const String _blobPath =
      'M70 210C28 130 84 36 186 46C292 56 352 118 332 196C312 274 204 304 '
      '126 284C96 276 78 244 70 210Z';

  /// SVG de la mancha de fondo de Detalle, con el degradado primario al 30%.
  static String detailBlobSvg() {
    final start = _hex(AppColors.gradientStart);
    final end = _hex(AppColors.gradientEnd);
    return '<svg viewBox="0 0 ${UiConfig.detailBlobCanvasWidth} '
        '${UiConfig.detailBlobCanvasHeight}">'
        '<defs><linearGradient id="blob" x1="0" y1="0" x2="1" y2="1">'
        '<stop offset="0" stop-color="$start" '
        'stop-opacity="$_blobGradientOpacity"/>'
        '<stop offset="1" stop-color="$end" '
        'stop-opacity="$_blobGradientOpacity"/>'
        '</linearGradient></defs>'
        '<path d="$_blobPath" fill="url(#blob)"/></svg>';
  }

  // Color como '#RRGGBB'.
  static String _hex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }
}
