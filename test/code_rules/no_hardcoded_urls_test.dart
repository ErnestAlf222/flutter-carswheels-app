import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('solo core/config contiene URLs', () {
    final urlScheme = RegExp(r'https?://');
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where(
          (file) =>
              !file.path.replaceAll(r'\', '/').contains('lib/core/config/'),
        );
    for (final file in files) {
      if (urlScheme.hasMatch(file.readAsStringSync())) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty);
  });
}
