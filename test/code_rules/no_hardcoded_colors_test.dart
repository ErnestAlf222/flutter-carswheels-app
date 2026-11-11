import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ningún archivo de lib/ fuera de core/theme usa Color(0x', () {
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where(
          (file) => !file.path.replaceAll(r'\', '/').contains('core/theme/'),
        );
    for (final file in files) {
      if (file.readAsStringSync().contains('Color(0x')) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty);
  });
}
