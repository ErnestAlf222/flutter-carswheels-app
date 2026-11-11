import 'package:cars_wheels_app/core/algorithms/algorithms.dart';
import 'package:cars_wheels_app/core/config/config.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sort_strategy_contract.dart';

/// Estrategia de prueba que registra si fue llamada.
class _RecordingStrategy implements SortStrategy<int> {
  final List<int> calls = [];
  bool get wasCalled => calls.isNotEmpty;

  @override
  List<int> sort(List<int> items, Comparator<int> compare) {
    calls.add(items.length);
    return List<int>.of(items);
  }
}

int _ascending(int a, int b) => a.compareTo(b);

List<int> _itemsOfLength(int length) => List<int>.generate(length, (i) => i);

void main() {
  group('AdaptiveSortStrategy', () {
    runSortStrategyContract(
      () => const AdaptiveSortStrategy<int>(
        smallListStrategy: BubbleSortStrategy<int>(),
        largeListStrategy: ShellSortStrategy<int>(),
      ),
    );

    test('usa burbuja con exactamente bubbleSortMaxItems elementos', () {
      final small = _RecordingStrategy();
      final large = _RecordingStrategy();
      AdaptiveSortStrategy<int>(
        smallListStrategy: small,
        largeListStrategy: large,
      ).sort(_itemsOfLength(AlgorithmsConfig.bubbleSortMaxItems), _ascending);
      expect(small.wasCalled, isTrue);
      expect(large.wasCalled, isFalse);
    });

    test('usa Shell con un elemento más que bubbleSortMaxItems', () {
      final small = _RecordingStrategy();
      final large = _RecordingStrategy();
      AdaptiveSortStrategy<int>(
        smallListStrategy: small,
        largeListStrategy: large,
      ).sort(
        _itemsOfLength(AlgorithmsConfig.bubbleSortMaxItems + 1),
        _ascending,
      );
      expect(small.wasCalled, isFalse);
      expect(large.wasCalled, isTrue);
    });
  });
}
