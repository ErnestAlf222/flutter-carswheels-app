import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ningún archivo de lib/ fuera de core/l10n usa Text con literal', () {
    final literalText = RegExp(r'''Text\(\s*['"]''');
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where(
          (file) => !file.path.replaceAll(r'\', '/').contains('core/l10n/'),
        );
    for (final file in files) {
      if (literalText.hasMatch(file.readAsStringSync())) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty);
  });
}
