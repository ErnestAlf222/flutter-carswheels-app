import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib/ no usa la paleta azul ni los degradados anteriores', () {
    final legacy = RegExp(
      r'gradientStart|gradientEnd|headerGradientEnd|pageGradientTop|'
      r'AppGradients\.(primary|header|page)\b|AppColors\.(link|tint|tintText)\b',
    );
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in files) {
      if (legacy.hasMatch(file.readAsStringSync())) offenders.add(file.path);
    }
    expect(offenders, isEmpty);
  });

  test('el amarillo nunca se usa como color de texto sobre fondo claro', () {
    // Solo los estilos sobre oscuro pueden tener texto amarillo.
    final source = File('lib/core/theme/app_text_styles.dart')
        .readAsStringSync();
    final yellowText = RegExp(r'color:\s*AppColors\.accent\b')
        .allMatches(source)
        .length;
    expect(yellowText, 1);
    expect(source, contains('onDarkWordmarkAccent'));
  });

  test(
    'ningún color derivado de accent con opacidad (se ve verde sobre tinta)',
    () {
      final derived = RegExp(
        r'AppColors\.accent(Pressed|Tint)?\s*\.\s*(withValues|withOpacity|withAlpha)',
      );
      final offenders = <String>[];
      final files = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      for (final file in files) {
        if (derived.hasMatch(file.readAsStringSync())) offenders.add(file.path);
      }
      expect(offenders, isEmpty);
    },
  );
}
