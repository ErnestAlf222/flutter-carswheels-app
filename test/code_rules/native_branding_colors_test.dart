import 'dart:io';

import 'package:cars_wheels_app/core/theme/app_colors.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

// Color en formato "#RRGGBB" tal como lo leen los generadores nativos.
String _hex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

// Valor de una clave en el pubspec; `section` limita la búsqueda a un bloque.
String? _value(String pubspec, String section, String key) {
  final lines = pubspec.split('\n');
  final start = lines.indexWhere((line) => line.startsWith('$section:'));
  if (start < 0) return null;
  for (final line in lines.skip(start + 1)) {
    if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('#')) {
      break;
    }
    final match = RegExp(r'^\s+' + key + r':\s*"?([^"\s]+)"?').firstMatch(line);
    if (match != null) return match.group(1);
  }
  return null;
}

void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final ink = _hex(AppColors.ink);

  test('el arranque nativo usa el color tinta de AppColors', () {
    expect(_value(pubspec, 'flutter_native_splash', 'color'), ink);
    expect(_value(pubspec, 'flutter_native_splash', 'color_dark'), ink);
    expect(
      _value(pubspec, 'flutter_native_splash', 'icon_background_color'),
      ink,
    );
  });

  test('el fondo del ícono adaptativo usa el color tinta de AppColors', () {
    expect(
      _value(pubspec, 'flutter_launcher_icons', 'adaptive_icon_background'),
      ink,
    );
  });

  test('los archivos nativos generados conservan el color tinta', () {
    final colors = File('android/app/src/main/res/values/colors.xml')
        .readAsStringSync();
    expect(colors, contains(ink));
  });
}
