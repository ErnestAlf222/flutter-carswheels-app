import 'package:flutter/painting.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Fondo donde se coloca el selector: encabezado tinta o fondo blanco.
enum MarketSelectorTone { onDark, onLight }

/// Colores del selector según su tono; todos salen de la paleta.
class MarketSelectorColors {
  const MarketSelectorColors._({
    required this.fill,
    required this.border,
    required this.foreground,
    required this.ring,
    required this.flagBorder,
    required this.divider,
  });

  /// Relleno de la píldora; transparente sobre tinta.
  final Color fill;
  final Color border;

  /// Año y chevron.
  final Color foreground;

  /// Aro fino de la bandera activa.
  final Color ring;
  final Color flagBorder;
  final Color divider;

  static final MarketSelectorColors _onDark = MarketSelectorColors._(
    fill: AppColors.transparent,
    border: AppColors.onDark.withValues(
      alpha: MarketConfig.selectorBorderOnDarkOpacity,
    ),
    foreground: AppColors.onDark,
    ring: AppColors.onDark,
    flagBorder: AppColors.onDark.withValues(
      alpha: MarketConfig.flagBadgeBorderOpacity,
    ),
    divider: AppColors.onDark.withValues(alpha: MarketConfig.dividerOpacity),
  );

  static const MarketSelectorColors _onLight = MarketSelectorColors._(
    fill: AppColors.surface,
    border: AppColors.outline,
    foreground: AppColors.ink,
    ring: AppColors.ink,
    flagBorder: AppColors.outline,
    divider: AppColors.outline,
  );

  static MarketSelectorColors of(MarketSelectorTone tone) =>
      tone == MarketSelectorTone.onDark ? _onDark : _onLight;
}
