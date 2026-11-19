import 'dart:async';

import 'package:cars_wheels_app/features/search/search.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/search_test_support.dart';

const Map<String, List<String>> _catalog = {
  'Audi': ['A3', 'A4', 'Q5'],
  'Ferrari': ['296 GTB', 'Roma'],
  'Ford': ['F-150', 'Mustang'],
  'Toyota': ['Camry', 'Corolla'],
};

/// Deja correr microtareas y temporizadores pendientes.
void _settle(FakeAsync async, [Duration time = const Duration(seconds: 1)]) {
  async.flushMicrotasks();
  async.elapse(time);
  async.flushMicrotasks();
}

/// Corre [body] con reloj falso, con el índice ya construido, y cierra el cubit.
void _run(SearchHarness harness, void Function(FakeAsync async) body) {
  fakeAsync((async) {
    harness.cubit.ensureIndex();
    _settle(async);
    body(async);
    unawaited(harness.cubit.close());
    _settle(async);
  });
}

void main() {
  test(
    'alcance Audi y "ferrari": nada en Audi, los Ferrari en otras marcas',
    () {
      final harness = SearchHarness(groupsByBrand: _catalog);
      _run(harness, (async) {
        harness.cubit.selectBrand('Audi');
        harness.cubit.onQueryChanged('ferrari');
        _settle(async);
        final state = harness.cubit.state;
        expect(state.scopeBrand, 'Audi');
        expect(state.results, isEmpty);
        expect(state.otherResults.map((r) => r.brand).toSet(), {'Ferrari'});
        expect(state.hasNoResultsInScope, isTrue);
        expect(state.hasNoResults, isFalse);
        expect(state.brandMatches, ['Ferrari']);
        // Quitar el alcance: todas pasan a la lista principal.
        harness.cubit.clearScopeBrand();
        expect(harness.cubit.state.results, hasLength(2));
        expect(harness.cubit.state.otherResults, isEmpty);
      });
    },
  );

  test('tocar una marca coincidente fija el alcance y limpia el texto', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    _run(harness, (async) {
      harness.cubit.onQueryChanged('ferrari');
      _settle(async);
      expect(harness.cubit.state.brandMatches, ['Ferrari']);
      harness.cubit.selectBrand('Ferrari');
      final state = harness.cubit.state;
      expect(state.scopeBrand, 'Ferrari');
      expect(state.query, '');
      expect(state.results, hasLength(2));
      expect(state.brandMatches, isEmpty);
    });
  });

  test('sin resultados ofrece sugerencias y tocar una reemplaza el texto', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    _run(harness, (async) {
      harness.cubit.onQueryChanged('ferari');
      _settle(async);
      final typed = harness.cubit.state;
      expect(typed.hasNoResults, isTrue);
      expect(typed.suggestions, ['ferrari']);
      // Nunca se sustituye solo: el texto sigue siendo el escrito.
      expect(typed.query, 'ferari');
      harness.cubit.applySuggestion('ferrari');
      final applied = harness.cubit.state;
      expect(applied.query, 'ferrari');
      expect(applied.results, hasLength(2));
      expect(applied.suggestions, isEmpty);
    });
  });

  test('con resultados no hay sugerencias', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    _run(harness, (async) {
      harness.cubit.onQueryChanged('f150');
      _settle(async);
      expect(harness.cubit.state.results, isNotEmpty);
      expect(harness.cubit.state.suggestions, isEmpty);
    });
  });

  test(
    'otros años: se ofrece, construye, entrega filas y no cambia el año',
    () {
      final harness = SearchHarness(groupsByBrand: _catalog);
      _run(harness, (async) {
        harness.cubit.onQueryChanged('zzzz');
        _settle(async);
        expect(harness.cubit.state.hasNoResults, isTrue);
        expect(harness.cubit.state.canSearchOtherYears, isTrue);
        harness.cubit.onQueryChanged('camry');
        _settle(async);
        expect(harness.cubit.state.results, isNotEmpty);
        harness.cubit.searchInOtherYears();
        _settle(async);
        final status = harness.cubit.state.otherYears!;
        expect(status.phase, SearchOtherYearsPhase.done);
        expect(status.results.map((r) => r.year), [2026, 2024, 2023]);
        // El alcance de la búsqueda no se movió de año.
        expect(harness.cubit.state.scope, usScope);
        expect(harness.cubit.state.canSearchOtherYears, isFalse);
      });
    },
  );

  test('la segunda pasada de otros años no pide nada a la red', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    _run(harness, (async) {
      harness.cubit.onQueryChanged('camry');
      _settle(async);
      harness.cubit.searchInOtherYears();
      _settle(async);
      final requests =
          harness.source.brandRequests + harness.source.groupRequests.length;
      harness.cubit.onQueryChanged('corolla');
      _settle(async);
      harness.cubit.searchInOtherYears();
      _settle(async);
      expect(
        harness.source.brandRequests + harness.source.groupRequests.length,
        requests,
      );
      expect(harness.cubit.state.otherYears!.results, isNotEmpty);
    });
  });

  test('cambiar el texto o cancelar detiene la búsqueda en otros años', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    _run(harness, (async) {
      harness.cubit.onQueryChanged('camry');
      _settle(async);
      harness.source.gate = Completer<void>();
      harness.cubit.searchInOtherYears();
      _settle(async);
      expect(harness.cubit.state.otherYears?.isBuilding, isTrue);
      harness.cubit.onQueryChanged('camr');
      expect(harness.cubit.state.otherYears, isNull);
      harness.source.gate!.complete();
      _settle(async);
      expect(harness.cubit.state.otherYears, isNull);
      harness.source.gate = Completer<void>();
      harness.cubit.searchInOtherYears();
      _settle(async);
      harness.cubit.cancelOtherYears();
      harness.source.gate!.complete();
      _settle(async);
      expect(harness.cubit.state.otherYears, isNull);
      expect(harness.cubit.state.canSearchOtherYears, isTrue);
    });
  });

  test('cambiar de año o de mercado cancela y limpia otros años', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    _run(harness, (async) {
      harness.cubit.onQueryChanged('camry');
      _settle(async);
      harness.source.gate = Completer<void>();
      harness.cubit.searchInOtherYears();
      _settle(async);
      harness.context.change(mxScope);
      harness.source.gate!.complete();
      harness.source.gate = null;
      _settle(async);
      expect(harness.cubit.state.otherYears, isNull);
      expect(harness.cubit.state.scope, mxScope);
    });
  });

  test('sin otros años en el catálogo no se ofrece', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    _run(harness, (async) {
      harness.context.years = const [2025];
      harness.cubit.onQueryChanged('zzzz');
      _settle(async);
      expect(harness.cubit.state.hasNoResults, isTrue);
      expect(harness.cubit.state.canSearchOtherYears, isFalse);
    });
  });

  test('sin alcance la búsqueda se comporta como antes', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    _run(harness, (async) {
      harness.cubit.onQueryChanged('fo');
      _settle(async);
      final state = harness.cubit.state;
      expect(state.scopeBrand, isNull);
      expect(state.otherResults, isEmpty);
      expect(state.results.map((r) => r.brand).toSet(), {'Ford'});
      expect(state.isTruncated, isFalse);
    });
  });
}
