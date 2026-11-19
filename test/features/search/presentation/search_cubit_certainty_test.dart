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

const Duration _debounce = Duration(milliseconds: 300);

/// Deja correr microtareas y temporizadores pendientes.
void _settle(FakeAsync async, [Duration time = const Duration(seconds: 1)]) {
  async.flushMicrotasks();
  async.elapse(time);
  async.flushMicrotasks();
}

/// Corre [body] con reloj falso y cierra el cubit; [build] decide si el índice se arma.
void _run(
  SearchHarness harness,
  void Function(FakeAsync async) body, {
  bool build = true,
}) {
  fakeAsync((async) {
    if (build) {
      harness.cubit.ensureIndex();
      _settle(async);
    }
    body(async);
    unawaited(harness.cubit.close());
    _settle(async);
  });
}

void main() {
  test('teclear "ferra" letra a letra nunca emite un vacío intermedio', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    _run(harness, (async) {
      final emitted = <SearchState>[];
      final subscription = harness.cubit.stream.listen(emitted.add);
      // Consultas de distinta duración: pausas cortas, largas y a toda prisa.
      const keystrokes = {
        'f': 50,
        'fe': 400,
        'fer': 120,
        'ferr': 700,
        'ferra': 10,
      };
      keystrokes.forEach((text, pause) {
        harness.cubit.onQueryChanged(text);
        async.elapse(Duration(milliseconds: pause));
      });
      _settle(async);
      unawaited(subscription.cancel());
      expect(emitted.where((state) => state.hasNoResults), isEmpty);
      expect(harness.cubit.state.results, isNotEmpty);
      expect(harness.cubit.state.isSearching, isFalse);
    });
  });

  test(
    'los resultados anteriores se conservan hasta que llegan los nuevos',
    () {
      final harness = SearchHarness(groupsByBrand: _catalog);
      _run(harness, (async) {
        harness.cubit.onQueryChanged('fer');
        _settle(async);
        final previous = harness.cubit.state.results;
        expect(previous, isNotEmpty);
        harness.cubit.onQueryChanged('ferr');
        async.elapse(const Duration(milliseconds: 100));
        expect(harness.cubit.state.results, previous);
        expect(harness.cubit.state.isSearching, isTrue);
        async.elapse(_debounce);
        expect(harness.cubit.state.results, isNotEmpty);
        expect(harness.cubit.state.isSearching, isFalse);
      });
    },
  );

  test('un texto sin coincidencias muestra el vacío solo tras la calma', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    _run(harness, (async) {
      harness.cubit.onQueryChanged('zzzx');
      expect(harness.cubit.state.hasNoResults, isFalse);
      async.elapse(_debounce - const Duration(milliseconds: 1));
      expect(harness.cubit.state.hasNoResults, isFalse);
      expect(harness.cubit.state.suggestions, isEmpty);
      async.elapse(const Duration(milliseconds: 1));
      expect(harness.cubit.state.hasNoResults, isTrue);
      expect(harness.cubit.state.isSearching, isFalse);
    });
  });

  test(
    'con el índice construyéndose un texto sin coincidencias no es vacío',
    () {
      final harness = SearchHarness(groupsByBrand: _catalog);
      _run(harness, (async) {
        harness.source.gate = Completer<void>();
        harness.cubit.ensureIndex();
        _settle(async);
        harness.cubit.onQueryChanged('zzzx');
        _settle(async);
        expect(harness.cubit.state.isPreparing, isTrue);
        expect(harness.cubit.state.hasNoResults, isFalse);
        expect(harness.cubit.state.suggestions, isEmpty);
        harness.source.gate!.complete();
        _settle(async);
        expect(harness.cubit.state.hasNoResults, isTrue);
      }, build: false);
    },
  );

  test('con el índice parcial un texto sin coincidencias no es vacío', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    harness.source.failingBrands.add('Audi');
    _run(harness, (async) {
      expect(harness.cubit.state.isPartial, isTrue);
      harness.cubit.onQueryChanged('zzzx');
      _settle(async);
      expect(harness.cubit.state.hasNoResults, isFalse);
      expect(harness.cubit.state.suggestions, isEmpty);
    });
  });

  test('un avance del índice no se salta el tiempo de calma', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    _run(harness, (async) {
      harness.source.gate = Completer<void>();
      harness.cubit.ensureIndex();
      _settle(async);
      harness.cubit.retryIndex();
      harness.cubit.onQueryChanged('zzzx');
      harness.source.gate!.complete();
      async.flushMicrotasks();
      expect(harness.cubit.state.indexStatus?.phase, SearchIndexPhase.ready);
      expect(harness.cubit.state.isSearching, isTrue);
      expect(harness.cubit.state.hasNoResults, isFalse);
      async.elapse(_debounce);
      expect(harness.cubit.state.hasNoResults, isTrue);
    }, build: false);
  });

  test('una búsqueda atrasada de un texto viejo no pisa a la nueva', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    _run(harness, (async) {
      harness.cubit.onQueryChanged('toy');
      async.elapse(const Duration(milliseconds: 250));
      harness.cubit.onQueryChanged('ferr');
      // El temporizador de "toy" habría vencido aquí: no debe aplicarse.
      async.elapse(const Duration(milliseconds: 100));
      expect(harness.cubit.state.searchedText, isNot('toy'));
      async.elapse(_debounce);
      expect(harness.cubit.state.searchedText, 'ferr');
      expect(
        harness.cubit.state.results.every((r) => r.brand == 'Ferrari'),
        isTrue,
      );
    });
  });

  test('borrar hasta menos del mínimo cancela la espera y no deja vacío', () {
    final harness = SearchHarness(groupsByBrand: _catalog);
    _run(harness, (async) {
      harness.cubit.onQueryChanged('zzzx');
      harness.cubit.onQueryChanged('z');
      _settle(async);
      expect(harness.cubit.state.isSearching, isFalse);
      expect(harness.cubit.state.hasNoResults, isFalse);
    });
  });
}
