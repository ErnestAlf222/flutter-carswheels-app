import 'dart:math';

import 'package:cars_wheels_app/core/algorithms/algorithms.dart';
import 'package:flutter_test/flutter_test.dart';

const int _randomSeed = 42;
const int _randomBound = 100000;
const int _bubbleMaxSize = 775;
const List<int> _sizes = [100, 775, 5000];

int _ascending(int a, int b) => a.compareTo(b);

/// Ejecuta la ordenación, imprime la medición y devuelve el resultado.
List<int> _measure(String name, int size, List<int> Function() run) {
  final stopwatch = Stopwatch()..start();
  final result = run();
  stopwatch.stop();
  // ignore: avoid_print
  print('$name | $size | ${stopwatch.elapsedMicroseconds}');
  return result;
}

void main() {
  test('compara tiempos y resultados de los algoritmos', () {
    final random = Random(_randomSeed);
    for (final size in _sizes) {
      final items = List<int>.generate(
        size,
        (_) => random.nextInt(_randomBound),
      );
      final dartSorted = _measure(
        'List.sort',
        size,
        () => List<int>.of(items)..sort(_ascending),
      );
      final shellSorted = _measure(
        'Shell',
        size,
        () => const ShellSortStrategy<int>().sort(items, _ascending),
      );
      expect(shellSorted, dartSorted);
      if (size <= _bubbleMaxSize) {
        final bubbleSorted = _measure(
          'Burbuja',
          size,
          () => const BubbleSortStrategy<int>().sort(items, _ascending),
        );
        expect(bubbleSorted, dartSorted);
      }
    }
  });
}
