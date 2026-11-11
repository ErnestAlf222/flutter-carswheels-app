import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('los barriles solo tienen exports, comentarios y blancos', () {
    const maxExports = 15;
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in files) {
      final lines = file.readAsLinesSync();
      final exportCount = lines.where((l) => l.startsWith('export ')).length;
      if (exportCount == 0) continue;
      final onlyAllowed = lines.every((line) {
        final text = line.trim();
        return text.isEmpty ||
            text.startsWith('//') ||
            text.startsWith('export ');
      });
      if (!onlyAllowed || exportCount > maxExports) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty);
  });
}
