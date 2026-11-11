import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('una feature solo importa el barril público de otra', () {
    final importPattern = RegExp(
      r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
    );
    final offenders = <String>[];
    final files = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in files) {
      final path = file.path.replaceAll(r'\', '/');
      final own = path.split('/')[2];
      for (final line in file.readAsLinesSync()) {
        final raw = importPattern.firstMatch(line)?.group(1);
        if (raw == null) continue;
        // Normaliza rutas de paquete y relativas a lib/...
        final target = raw.startsWith('package:cars_wheels_app/')
            ? 'lib/${raw.substring('package:cars_wheels_app/'.length)}'
            : raw.startsWith('package:') || raw.startsWith('dart:')
            ? null
            : Uri.parse(path).resolve(raw).path;
        if (target == null) continue;
        final parts = target.split('/');
        if (parts.length < 4 || parts[1] != 'features') continue;
        final other = parts[2];
        if (other != own && target != 'lib/features/$other/$other.dart') {
          offenders.add('${file.path} -> $raw');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
