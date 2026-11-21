import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextNormalizer.compare', () {
    test('ordena por nombre normalizado', () {
      expect(TextNormalizer.compare('Audi', 'BMW'), lessThan(0));
      expect(TextNormalizer.compare('Citroën', 'citroen'), isNot(0));
    });

    test('desempata por el texto original: orden total y determinista', () {
      expect(TextNormalizer.compare('Land Rover', 'LandRover'), isNot(0));
      final a = ['Land-Rover', 'Land Rover', 'LANDROVER'];
      final b = [...a.reversed];
      final sortedA = [...a]..sort(TextNormalizer.compare);
      final sortedB = [...b]..sort(TextNormalizer.compare);
      expect(sortedA, sortedB);
    });

    test(
      'cualquier orden de entrada da el mismo resultado con las estrategias',
      () {
        const names = ['b-x', 'bx', 'B X', 'a', 'A'];
        final expected = [...names]..sort(TextNormalizer.compare);
        for (final strategy in [
          const BubbleSortStrategy<String>(),
          const ShellSortStrategy<String>(),
        ]) {
          expect(strategy.sort(names, TextNormalizer.compare), expected);
          expect(
            strategy.sort([...names.reversed], TextNormalizer.compare),
            expected,
          );
        }
      },
    );
  });
}
