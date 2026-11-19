import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/search_test_support.dart';

const SearchScopeEntity _usScope2026 = SearchScopeEntity(
  marketCode: 'us',
  year: 2026,
);

/// Deja correr microtareas y temporizadores pendientes.
void _settle(FakeAsync async, [Duration time = const Duration(seconds: 1)]) {
  async.flushMicrotasks();
  async.elapse(time);
  async.flushMicrotasks();
}

/// Corre [body] con reloj falso y cierra el cubit al terminar.
void _run(SearchHarness harness, void Function(FakeAsync async) body) {
  fakeAsync((async) {
    body(async);
    unawaited(harness.cubit.close());
    _settle(async);
  });
}

int _networkRequests(SearchHarness harness) =>
    harness.source.brandRequests + harness.source.groupRequests.length;

void main() {
  test('sin pedirlo no se construye nada al arrancar', () {
    final harness = SearchHarness();
    _run(harness, (async) {
      _settle(async);
      expect(harness.source.brandRequests, 0);
      expect(harness.cubit.state.indexStatus, isNull);
    });
  });

  test('ensureIndex construye, queda listo y trae recientes y marcas', () {
    final harness = SearchHarness();
    harness.recents.stored = [
      RecentSearchEntity(
        key: 'civic',
        text: 'Civic',
        searchedAt: DateTime(2026),
      ),
    ];
    _run(harness, (async) {
      harness.cubit.ensureIndex();
      _settle(async);
      final state = harness.cubit.state;
      expect(state.indexStatus?.phase, SearchIndexPhase.ready);
      expect(state.recents.single.text, 'Civic');
      // Toyota (3 grupos) primero, luego Honda y Hyundai con 2 (alfabético).
      expect(state.quickBrands, ['Toyota', 'Honda', 'Hyundai']);
    });
  });

  test('las marcas rápidas respetan el tope de config', () {
    final harness = SearchHarness(
      groupsByBrand: {
        for (int i = 0; i < SearchConfig.quickBrandCount + 3; i++)
          'Marca$i': ['G$i'],
      },
    );
    _run(harness, (async) {
      harness.cubit.ensureIndex();
      _settle(async);
      expect(
        harness.cubit.state.quickBrands,
        hasLength(SearchConfig.quickBrandCount),
      );
    });
  });

  group('consulta', () {
    test('espera el debounce antes de buscar', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        harness.cubit.ensureIndex();
        _settle(async);
        harness.cubit.onQueryChanged('toy');
        async.elapse(const Duration(milliseconds: 299));
        expect(harness.cubit.state.results, isEmpty);
        async.elapse(const Duration(milliseconds: 1));
        expect(harness.cubit.state.results, isNotEmpty);
        expect(harness.cubit.state.results.first.brand, 'Toyota');
      });
    });

    test('teclear de nuevo reinicia la espera', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        harness.cubit.ensureIndex();
        _settle(async);
        harness.cubit.onQueryChanged('toy');
        async.elapse(const Duration(milliseconds: 200));
        harness.cubit.onQueryChanged('toyo');
        async.elapse(const Duration(milliseconds: 200));
        expect(harness.cubit.state.results, isEmpty);
        async.elapse(const Duration(milliseconds: 100));
        expect(harness.cubit.state.results, isNotEmpty);
      });
    });

    test('con menos del mínimo no hay resultados ni espera', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        harness.cubit.ensureIndex();
        _settle(async);
        harness.cubit.onQueryChanged('toy');
        _settle(async);
        expect(harness.cubit.state.results, isNotEmpty);
        harness.cubit.onQueryChanged('t');
        // Se vacía al instante, sin esperar el debounce.
        expect(harness.cubit.state.results, isEmpty);
        expect(harness.cubit.state.hasQuery, isFalse);
      });
    });

    test('sin consulta no hay resultados', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        harness.cubit.ensureIndex();
        _settle(async);
        harness.cubit.onQueryChanged('toy');
        _settle(async);
        harness.cubit.clearQuery();
        expect(harness.cubit.state.results, isEmpty);
        expect(harness.cubit.state.query, '');
      });
    });

    test('una marca sola filtra: lista sus grupos sin tope de resultados', () {
      final harness = SearchHarness(
        groupsByBrand: {
          'Toyota': [
            for (int i = 0; i < 80; i++)
              'Modelo ${i.toString().padLeft(2, '0')}',
          ],
          'Honda': ['Civic'],
        },
      );
      _run(harness, (async) {
        harness.cubit.ensureIndex();
        _settle(async);
        harness.cubit.selectBrand('Toyota');
        final state = harness.cubit.state;
        expect(state.brandFilter, 'Toyota');
        expect(state.query, 'Toyota');
        expect(state.results, hasLength(80));
        expect(state.results.every((r) => r.brand == 'Toyota'), isTrue);
        expect(state.results.every((r) => !r.isBrandOnly), isTrue);
        // Escribir de nuevo sale del filtro.
        harness.cubit.onQueryChanged('hon');
        expect(harness.cubit.state.brandFilter, isNull);
      });
    });
  });

  group('índice', () {
    test('muestra el progreso y se puede buscar por marca de inmediato', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        harness.source.gate = Completer<void>();
        harness.cubit.ensureIndex();
        _settle(async);
        expect(
          harness.cubit.state.indexStatus?.phase,
          SearchIndexPhase.building,
        );
        expect(harness.cubit.state.isPreparing, isTrue);
        harness.cubit.onQueryChanged('toy');
        _settle(async);
        expect(harness.cubit.state.results.single.isBrandOnly, isTrue);
        harness.source.gate!.complete();
        _settle(async);
        expect(harness.cubit.state.indexStatus?.phase, SearchIndexPhase.ready);
        // La consulta vigente se repitió con los grupos ya cargados.
        expect(harness.cubit.state.results.length, greaterThan(1));
      });
    });

    test('los resultados ya mostrados no se pierden mientras avanza', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        harness.source.gate = Completer<void>();
        harness.cubit.ensureIndex();
        _settle(async);
        harness.cubit.onQueryChanged('toy');
        _settle(async);
        final shown = harness.cubit.state.results;
        expect(shown, isNotEmpty);
        harness.source.gate!.complete();
        _settle(async);
        expect(harness.cubit.state.results, containsAll(shown));
      });
    });

    test('parcial: avisa y reintenta solo las marcas fallidas', () {
      final harness = SearchHarness();
      harness.source.failingBrands.add('Honda');
      _run(harness, (async) {
        harness.cubit.ensureIndex();
        _settle(async);
        expect(harness.cubit.state.isPartial, isTrue);
        expect(harness.cubit.state.indexStatus?.failedBrands, ['Honda']);
        harness.source.failingBrands.clear();
        harness.source.groupRequests.clear();
        harness.cubit.retryIndex();
        _settle(async);
        expect(harness.source.groupRequests, ['Honda']);
        expect(harness.cubit.state.indexStatus?.phase, SearchIndexPhase.ready);
        harness.cubit.onQueryChanged('civic');
        _settle(async);
        expect(harness.cubit.state.results.single.groupName, 'Civic');
      });
    });

    test('sin conexión queda en error y reintentar lo recupera', () {
      final harness = SearchHarness();
      harness.source.failBrands = true;
      _run(harness, (async) {
        harness.cubit.ensureIndex();
        _settle(async);
        expect(harness.cubit.state.hasBlockingError, isTrue);
        harness.source.failBrands = false;
        harness.cubit.retryIndex();
        _settle(async);
        expect(harness.cubit.state.hasBlockingError, isFalse);
        expect(harness.cubit.state.indexStatus?.phase, SearchIndexPhase.ready);
      });
    });

    test('la segunda entrada no vuelve a pedir nada a la red', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        harness.cubit.ensureIndex();
        _settle(async);
        final requests = _networkRequests(harness);
        harness.cubit.ensureIndex();
        _settle(async);
        expect(_networkRequests(harness), requests);
      });
    });
  });

  group('mercado y año', () {
    test('al cambiar de año cancela, reconstruye y repite la consulta', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        harness.source.gate = Completer<void>();
        harness.cubit.ensureIndex();
        _settle(async);
        harness.cubit.onQueryChanged('toy');
        _settle(async);
        expect(
          harness.cubit.state.indexStatus?.phase,
          SearchIndexPhase.building,
        );
        harness.source.gate!.complete();
        harness.source.gate = null;
        harness.context.change(_usScope2026);
        _settle(async);
        final state = harness.cubit.state;
        expect(state.scope, _usScope2026);
        expect(harness.source.scopes.last, _usScope2026);
        expect(state.indexStatus?.phase, SearchIndexPhase.ready);
        expect(state.query, 'toy');
        expect(state.results.every((r) => r.year == 2026), isTrue);
        expect(state.results.length, greaterThan(1));
      });
    });

    test('al cambiar de mercado el alcance nulo no busca y el nuevo sí', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        harness.cubit.ensureIndex();
        _settle(async);
        harness.cubit.onQueryChanged('toy');
        _settle(async);
        harness.context.change(null);
        _settle(async);
        expect(harness.cubit.state.results, isEmpty);
        expect(harness.cubit.state.indexStatus, isNull);
        harness.context.change(mxScope);
        _settle(async);
        expect(harness.cubit.state.scope, mxScope);
        expect(
          harness.cubit.state.results.every((r) => r.marketCode == 'mx'),
          isTrue,
        );
        expect(harness.cubit.state.results, isNotEmpty);
      });
    });

    test(
      'si el catálogo aún no estaba listo, construye al llegar el alcance',
      () {
        final harness = SearchHarness(initialScope: null);
        _run(harness, (async) {
          harness.cubit.ensureIndex();
          _settle(async);
          expect(harness.source.brandRequests, 0);
          harness.context.change(usScope);
          _settle(async);
          expect(
            harness.cubit.state.indexStatus?.phase,
            SearchIndexPhase.ready,
          );
        });
      },
    );
  });

  group('recientes', () {
    test('teclear no guarda; enviar sí', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        harness.cubit.ensureIndex();
        _settle(async);
        harness.cubit.onQueryChanged('toyota');
        _settle(async);
        expect(harness.recents.stored, isEmpty);
        unawaited(harness.cubit.submit());
        _settle(async);
        expect(harness.recents.stored.single.text, 'toyota');
        expect(harness.cubit.state.recents.single.text, 'toyota');
      });
    });

    test('tocar un resultado guarda la consulta', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        harness.cubit.ensureIndex();
        _settle(async);
        harness.cubit.onQueryChanged('cam');
        _settle(async);
        unawaited(harness.cubit.registerResultTap());
        _settle(async);
        expect(harness.recents.stored.single.key, 'cam');
      });
    });

    test('con menos del mínimo no se guarda', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        harness.cubit.onQueryChanged('c');
        unawaited(harness.cubit.submit());
        _settle(async);
        expect(harness.recents.stored, isEmpty);
      });
    });

    test('sin duplicados: la repetida sube al inicio', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        for (final text in ['toyota', 'honda', 'Toyota']) {
          harness.cubit.onQueryChanged(text);
          unawaited(harness.cubit.submit());
          _settle(async);
        }
        expect(
          [for (final r in harness.recents.stored) r.key],
          ['toyota', 'honda'],
        );
        expect(harness.recents.stored.first.text, 'Toyota');
      });
    });

    test('respeta el tope de recientes', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        for (int i = 0; i < SearchConfig.maxRecentSearches + 4; i++) {
          harness.cubit.onQueryChanged('busqueda $i');
          unawaited(harness.cubit.submit());
          _settle(async);
        }
        expect(
          harness.recents.stored,
          hasLength(SearchConfig.maxRecentSearches),
        );
        expect(
          harness.cubit.state.recents,
          hasLength(SearchConfig.maxRecentSearches),
        );
      });
    });

    test('repetir una reciente busca al instante; borrar una y todo', () {
      final harness = SearchHarness();
      _run(harness, (async) {
        harness.cubit.ensureIndex();
        _settle(async);
        harness.cubit.onQueryChanged('honda');
        unawaited(harness.cubit.submit());
        _settle(async);
        harness.cubit.onQueryChanged('toyota');
        unawaited(harness.cubit.submit());
        _settle(async);
        harness.cubit.clearQuery();
        unawaited(harness.cubit.useRecent(harness.cubit.state.recents.last));
        // Sin esperar el debounce.
        expect(harness.cubit.state.query, 'honda');
        expect(harness.cubit.state.results.first.brand, 'Honda');
        _settle(async);
        unawaited(harness.cubit.removeRecentSearch('honda'));
        _settle(async);
        expect(
          [for (final r in harness.cubit.state.recents) r.key],
          ['toyota'],
        );
        unawaited(harness.cubit.clearRecentSearches());
        _settle(async);
        expect(harness.cubit.state.recents, isEmpty);
      });
    });
  });

  test('requestFocus se atiende una sola vez', () {
    final harness = SearchHarness();
    _run(harness, (async) {
      expect(harness.cubit.takeFocusRequest(), isFalse);
      harness.cubit.requestFocus();
      expect(harness.cubit.takeFocusRequest(), isTrue);
      expect(harness.cubit.takeFocusRequest(), isFalse);
    });
  });

  test('cerrar cancela la construcción y libera el contexto', () async {
    final harness = SearchHarness();
    harness.source.gate = Completer<void>();
    harness.cubit.ensureIndex();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(harness.store.recordOf(usScope.key), isNotNull);
    await harness.cubit.close();
    expect(harness.context.closed, isTrue);
    // El índice incompleto se descarta.
    expect(harness.store.recordOf(usScope.key), isNull);
  });
}
