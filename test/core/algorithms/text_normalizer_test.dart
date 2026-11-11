import 'package:cars_wheels_app/core/algorithms/algorithms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextNormalizer.normalize', () {
    test('quita espacios y guiones', () {
      expect(TextNormalizer.normalize('Ford F-150'), 'fordf150');
    });

    test('reemplaza ñ y acentos', () {
      expect(TextNormalizer.normalize('Ñandú'), 'nandu');
    });

    test('mayúsculas acentuadas y diéresis', () {
      expect(TextNormalizer.normalize('ÁÉÍÓÚ ü'), 'aeiouu');
    });

    test('cadena vacía', () {
      expect(TextNormalizer.normalize(''), '');
    });

    test('texto ya normalizado', () {
      expect(TextNormalizer.normalize('fordf150'), 'fordf150');
    });
  });
}
