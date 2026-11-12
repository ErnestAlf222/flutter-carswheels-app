import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ningún .dart de lib/ ni test/ usa la palabra var', () {
    final varToken = RegExp(r'\bvar\b');
    final offenders = <String>[];
    for (final root in ['lib', 'test']) {
      final files = Directory(root)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          // El código generado por build_runner no se escribe a mano.
          .where((file) => !file.path.endsWith('.g.dart'))
          .where(
            (file) =>
                !file.path.replaceAll(r'\', '/').contains('test/code_rules/'),
          );
      for (final file in files) {
        if (varToken.hasMatch(file.readAsStringSync())) {
          offenders.add(file.path);
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
