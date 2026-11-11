import 'package:cars_wheels_app/core/algorithms/algorithms.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sort_strategy_contract.dart';

void main() {
  group('ShellSortStrategy', () {
    runSortStrategyContract(() => const ShellSortStrategy<int>());
  });
}
