import 'dart:math';

import 'package:cars_wheels_app/core/algorithms/algorithms.dart';
import 'package:flutter_test/flutter_test.dart';

const int _randomSeed = 42;
const int _randomBound = 1000;
const List<int> _randomSizes = [0, 1, 2, 10, 20, 21, 100, 775];

int _ascending(int a, int b) => a.compareTo(b);

/// Pruebas comunes que toda estrategia de ordenamiento debe cumplir.
void runSortStrategyContract(SortStrategy<int> Function() create) {
  test('lista vacía', () {
    expect(create().sort(<int>[], _ascending), isEmpty);
  });

  test('un elemento', () {
    expect(create().sort([7], _ascending), [7]);
  });

  test('ya ordenada', () {
    expect(create().sort([1, 2, 3, 4], _ascending), [1, 2, 3, 4]);
  });

  test('invertida', () {
    expect(create().sort([5, 4, 3, 2, 1], _ascending), [1, 2, 3, 4, 5]);
  });

  test('con duplicados', () {
    expect(create().sort([3, 1, 3, 2, 1], _ascending), [1, 1, 2, 3, 3]);
  });

  test('con números negativos', () {
    expect(create().sort([2, -5, 0, -1, 4], _ascending), [-5, -1, 0, 2, 4]);
  });

  test('no modifica la lista original', () {
    final original = [3, 1, 2];
    final result = create().sort(original, _ascending);
    expect(original, [3, 1, 2]);
    expect(identical(result, original), isFalse);
  });

  test('coincide con List.sort en listas aleatorias', () {
    final random = Random(_randomSeed);
    for (final size in _randomSizes) {
      final items = List<int>.generate(
        size,
        (_) => random.nextInt(_randomBound),
      );
      final expected = List<int>.of(items)..sort(_ascending);
      expect(create().sort(items, _ascending), expected, reason: 'size $size');
    }
  });
}
