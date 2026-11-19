import 'dart:math' as math;

import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

// Luminancia relativa WCAG de un color sRGB.
double _luminance(Color color) {
  double channel(double value) => value <= 0.03928
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

// Contraste de a sobre b; si a es translúcido se compone antes sobre b.
double _contrast(Color a, Color b) {
  final top = Color.alphaBlend(a, b);
  final la = _luminance(top);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('blanco sobre tinta llega a 12:1', () {
    expect(
      _contrast(AppColors.onDark, AppColors.ink),
      greaterThanOrEqualTo(12),
    );
  });

  test('tinta sobre amarillo llega a 9:1, también al presionar', () {
    expect(_contrast(AppColors.ink, AppColors.accent), greaterThanOrEqualTo(9));
    expect(
      _contrast(AppColors.ink, AppColors.accentPressed),
      greaterThanOrEqualTo(9),
    );
  });

  test('el texto secundario se lee sobre el fondo y sobre blanco', () {
    expect(
      _contrast(AppColors.mutedText, AppColors.background),
      greaterThanOrEqualTo(HeaderConfig.minContrastRatio),
    );
    expect(
      _contrast(AppColors.mutedText, AppColors.surface),
      greaterThanOrEqualTo(HeaderConfig.minContrastRatio),
    );
  });

  test('el texto secundario sobre oscuro se lee sobre tinta y tinta suave', () {
    for (final dark in [AppColors.ink, AppColors.inkSoft]) {
      expect(
        _contrast(AppColors.mutedOnDark, dark),
        greaterThanOrEqualTo(HeaderConfig.minContrastRatio),
      );
    }
  });

  test('el amarillo como texto o ícono se lee sobre oscuro', () {
    expect(
      _contrast(AppColors.accent, AppColors.ink),
      greaterThanOrEqualTo(HeaderConfig.minContrastRatio),
    );
  });

  test('los íconos de motorización se ven sobre blanco (3:1)', () {
    const colors = [
      AppColors.engineElectric,
      AppColors.enginePluginHybrid,
      AppColors.engineHybrid,
      AppColors.engineHydrogen,
      AppColors.engineDiesel,
      AppColors.engineFuel,
    ];
    for (final color in colors) {
      expect(
        _contrast(color, AppColors.surface),
        greaterThanOrEqualTo(HeaderConfig.minIconContrastRatio),
        reason: '$color',
      );
    }
  });

  test('el ícono inactivo de la barra inferior se lee sobre tinta', () {
    expect(
      _contrast(AppColors.navInactive, AppColors.ink),
      greaterThanOrEqualTo(HeaderConfig.minIconContrastRatio),
    );
  });
}
