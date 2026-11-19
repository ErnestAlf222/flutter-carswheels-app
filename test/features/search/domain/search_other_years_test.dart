import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/search_test_support.dart';

const Map<String, List<String>> _catalog = {
  'Ford': ['F-150', 'Mustang'],
  'Toyota': ['Camry', 'Corolla'],
};

const List<int> _years = [2026, 2025, 2024, 2023, 2022];

int _requests(SearchHarness harness) =>
    harness.source.brandRequests + harness.source.groupRequests.length;

Stream<SearchOtherYearsStatusEntity> _run(
  SearchHarness harness,
  String query, {
  List<int> years = _years,
}) => harness.otherYears(scope: usScope, query: query, availableYears: years);

void main() {
  test('construye los años cercanos y entrega sus coincidencias', () async {
    final harness = SearchHarness(groupsByBrand: _catalog);
    final statuses = await _run(harness, 'f-150').toList();
    final last = statuses.last;
    expect(last.phase, SearchOtherYearsPhase.done);
    expect(last.progress, 1);
    // Vigente 2025: 2026 y 2024 (empate, gana el reciente) y luego 2023.
    expect(last.checkedYears, [2026, 2024, 2023]);
    expect(last.checkedYears, hasLength(SearchConfig.otherYearsCount));
    expect(last.results.map((r) => r.year), [2026, 2024, 2023]);
    expect(last.results.every((r) => r.groupName == 'F-150'), isTrue);
    expect(last.results.every((r) => r.marketCode == 'us'), isTrue);
    expect(last.failedYears, isEmpty);
    // El año vigente nunca se vuelve a construir.
    expect(harness.source.scopes.map((s) => s.year).toSet(), {
      2026,
      2024,
      2023,
    });
  });

  test('el avance sube de 0 a 1 y solo la última fase es done', () async {
    final harness = SearchHarness(groupsByBrand: _catalog);
    final statuses = await _run(harness, 'f-150').toList();
    expect(statuses.first.progress, 0);
    expect(statuses.first.isBuilding, isTrue);
    final progress = [for (final s in statuses) s.progress];
    for (int i = 1; i < progress.length; i++) {
      expect(progress[i], greaterThanOrEqualTo(progress[i - 1]));
    }
    expect(statuses.where((s) => !s.isBuilding), hasLength(1));
    expect(statuses.last.isBuilding, isFalse);
  });

  test('segunda pasada: cero peticiones (índices en el almacén)', () async {
    final harness = SearchHarness(groupsByBrand: _catalog);
    await _run(harness, 'f-150').drain<void>();
    final before = _requests(harness);
    expect(before, greaterThan(0));
    final second = await _run(harness, 'camry').toList();
    expect(_requests(harness), before);
    expect(second.last.results.map((r) => r.groupName), [
      'Camry',
      'Camry',
      'Camry',
    ]);
  });

  test('México solo tiene 2 años: busca en el único otro', () async {
    final harness = SearchHarness(groupsByBrand: _catalog);
    final statuses = await harness
        .otherYears(
          scope: mxScope,
          query: 'camry',
          availableYears: [2026, 2025],
        )
        .toList();
    expect(statuses.last.checkedYears, [2026]);
    expect(statuses.last.results, hasLength(1));
    expect(statuses.last.results.single.marketCode, 'mx');
  });

  test('cancelar detiene la construcción sin emitir el estado final', () async {
    final harness = SearchHarness(groupsByBrand: _catalog);
    harness.source.gate = Completer<void>();
    final statuses = <SearchOtherYearsStatusEntity>[];
    final done = Completer<void>();
    _run(harness, 'f-150').listen(statuses.add, onDone: done.complete);
    await Future<void>.delayed(Duration.zero);
    harness.otherYears.cancel();
    harness.source.gate!.complete();
    await done.future.timeout(const Duration(seconds: 2));
    expect(statuses.every((s) => s.isBuilding), isTrue);
    expect(statuses.every((s) => s.results.isEmpty), isTrue);
    // No siguió pidiendo años: solo los grupos de la primera marca en vuelo.
    expect(harness.source.scopes.map((s) => s.year).toSet(), {2026});
  });

  test('un año que falla se informa y los demás siguen', () async {
    final harness = SearchHarness(groupsByBrand: _catalog);
    harness.source.failBrands = true;
    final statuses = await _run(harness, 'camry').toList();
    expect(statuses.last.phase, SearchOtherYearsPhase.done);
    expect(statuses.last.failedYears, [2026, 2024, 2023]);
    expect(statuses.last.results, isEmpty);
  });

  test('sin otros años termina de inmediato y vacío', () async {
    final harness = SearchHarness(groupsByBrand: _catalog);
    final statuses = await _run(harness, 'camry', years: [2025]).toList();
    expect(statuses.last.phase, SearchOtherYearsPhase.done);
    expect(statuses.last.checkedYears, isEmpty);
    expect(_requests(harness), 0);
  });

  test('el tope de filas halladas es el de config', () async {
    final harness = SearchHarness(
      groupsByBrand: {
        'Toyota': [for (int i = 0; i < 40; i++) 'Modelo $i'],
      },
    );
    final statuses = await _run(harness, 'modelo').toList();
    expect(statuses.last.results, hasLength(SearchConfig.maxOtherYearsResults));
  });
}
