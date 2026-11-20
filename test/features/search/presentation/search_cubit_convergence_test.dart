import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/search_test_support.dart';

const Map<String, List<String>> _catalog = {
  'Audi': ['A3', 'A4'],
  'Ferrari': ['296 GTB', 'Roma', 'SF90', '812', 'Purosangue', '12Cilindri'],
  'Ford': ['F-150', 'Mustang'],
  'Toyota': ['Camry', 'Corolla'],
};

void _settle(FakeAsync async, [Duration time = const Duration(seconds: 1)]) {
  async.flushMicrotasks();
  async.elapse(time);
  async.flushMicrotasks();
}

void main() {
  test('escribir durante la construcción converge al conjunto completo', () {
    fakeAsync((async) {
      final harness = SearchHarness(groupsByBrand: _catalog);
      for (final brand in _catalog.keys) {
        harness.source.brandGates[brand] = Completer<void>();
      }
      harness.cubit.ensureIndex();
      _settle(async);
      harness.cubit.onQueryChanged('ferrari');
      _settle(async);
      expect(harness.cubit.state.results, isEmpty);
      // Las marcas terminan en momentos distintos; Ferrari al final.
      for (final brand in ['Audi', 'Toyota', 'Ford', 'Ferrari']) {
        harness.source.brandGates[brand]!.complete();
        _settle(async, const Duration(milliseconds: 200));
      }
      expect(harness.cubit.state.results.length, 6);
      expect(harness.cubit.state.indexStatus?.phase, SearchIndexPhase.ready);
      unawaited(harness.cubit.close());
      _settle(async);
    });
  });

  test(
    'una marca que falla deja el índice parcial, se reintenta sola y converge',
    () {
      fakeAsync((async) {
        final harness = SearchHarness(groupsByBrand: _catalog);
        harness.source.failuresLeft['Ferrari'] = 1;
        harness.cubit.ensureIndex();
        _settle(async, const Duration(milliseconds: 100));
        harness.cubit.onQueryChanged('ferrari');
        _settle(async, const Duration(milliseconds: 400));
        expect(harness.cubit.state.isPartial, isTrue);
        expect(harness.cubit.state.results, isEmpty);
        // Sin tocar nada, el reintento automático completa los resultados.
        _settle(async, const Duration(minutes: 1));
        expect(harness.cubit.state.results.length, 6);
        expect(harness.cubit.state.indexStatus?.phase, SearchIndexPhase.ready);
        unawaited(harness.cubit.close());
        _settle(async);
      });
    },
  );

  test('una marca vacía repetida se confirma, el índice queda listo y afirma sin resultados', () {
    fakeAsync((async) {
      final harness = SearchHarness(groupsByBrand: _catalog);
      harness.source.emptyBrands.add('Ferrari');
      harness.cubit.ensureIndex();
      _settle(async, const Duration(milliseconds: 100));
      // La primera respuesta vacía aún no es consistente: queda pendiente.
      SearchIndexRecord record = harness.store.recordOf(usScope.key)!;
      expect(record.status.phase, SearchIndexPhase.partial);
      expect(record.status.failedBrands, ['Ferrari']);
      expect(record.isConsistent, isTrue);
      // El reintento automático repite la respuesta vacía y la confirma.
      _settle(
        async,
        const Duration(
          milliseconds: SearchConfig.indexRetryBaseDelayMilliseconds,
        ),
      );
      record = harness.store.recordOf(usScope.key)!;
      expect(record.status.phase, SearchIndexPhase.ready);
      expect(record.status.failedBrands, isEmpty);
      expect(record.status.emptyBrands, ['Ferrari']);
      expect(record.isConsistent, isTrue);
      expect(harness.cubit.state.isPartial, isFalse);
      // Sin más reintentos: la marca vacía no se vuelve a pedir.
      _settle(async, const Duration(minutes: 10));
      expect(
        harness.source.groupRequests.where((b) => b == 'Ferrari').length,
        SearchConfig.emptyBrandConfirmations,
      );
      harness.cubit.onQueryChanged('ferrari modelo');
      _settle(async, const Duration(milliseconds: 600));
      expect(harness.cubit.state.results, isEmpty);
      expect(harness.cubit.state.isPartial, isFalse);
      unawaited(harness.cubit.close());
      _settle(async);
    });
  });

  test('con una marca que nunca responde bien reintenta con retroceso y se detiene', () {
    fakeAsync((async) {
      final harness = SearchHarness(groupsByBrand: _catalog);
      harness.source.failingBrands.add('Ferrari');
      harness.cubit.ensureIndex();
      _settle(async, const Duration(milliseconds: 100));
      expect(
        harness.source.groupRequests.where((b) => b == 'Ferrari').length,
        1,
      );
      // Primer reintento tras la espera base, el segundo tras el doble.
      async.elapse(
        const Duration(
          milliseconds: SearchConfig.indexRetryBaseDelayMilliseconds,
        ),
      );
      async.flushMicrotasks();
      expect(
        harness.source.groupRequests.where((b) => b == 'Ferrari').length,
        2,
      );
      async.elapse(
        const Duration(
          milliseconds:
              SearchConfig.indexRetryBaseDelayMilliseconds *
              SearchConfig.indexRetryBackoffFactor,
        ),
      );
      async.flushMicrotasks();
      expect(
        harness.source.groupRequests.where((b) => b == 'Ferrari').length,
        3,
      );
      // Pasado el tope de intentos ya no insiste solo.
      _settle(async, const Duration(minutes: 10));
      expect(
        harness.source.groupRequests.where((b) => b == 'Ferrari').length,
        1 + SearchConfig.indexRetryMaxAttempts,
      );
      expect(harness.cubit.state.isPartial, isTrue);
      unawaited(harness.cubit.close());
      _settle(async);
    });
  });

  test('un índice listo pero inconsistente en el almacén se descarta y se reconstruye', () {
    fakeAsync((async) {
      final harness = SearchHarness(groupsByBrand: _catalog);
      // Dice "listo" para 4 marcas, pero solo trae una fila de marca.
      harness.store.save(
        usScope.key,
        SearchIndexRecord(
          index: SearchIndex.build([
            const SearchEntryEntity(brand: 'Audi'),
          ], postingSort),
          status: const SearchIndexStatusEntity.ready(totalBrands: 4),
        ),
      );
      harness.cubit.ensureIndex();
      _settle(async);
      expect(harness.source.brandRequests, 1);
      final record = harness.store.recordOf(usScope.key)!;
      expect(record.isConsistent, isTrue);
      expect(record.status.phase, SearchIndexPhase.ready);
      harness.cubit.onQueryChanged('ferrari');
      _settle(async);
      expect(harness.cubit.state.results.length, 6);
      unawaited(harness.cubit.close());
      _settle(async);
    });
  });

  test('cambiar de año a media consulta no mezcla índices', () {
    fakeAsync((async) {
      final harness = SearchHarness(groupsByBrand: _catalog);
      harness.source.brandGates['Ferrari'] = Completer<void>();
      harness.cubit.ensureIndex();
      _settle(async);
      harness.cubit.onQueryChanged('audi');
      _settle(async);
      expect(harness.cubit.state.results, isNotEmpty);
      const other = SearchScopeEntity(marketCode: 'us', year: 2024);
      harness.context.change(other);
      _settle(async, const Duration(milliseconds: 50));
      // Con el año nuevo a medias, nada del año anterior se muestra.
      expect(harness.cubit.state.scope, other);
      expect(harness.cubit.state.results.every((r) => r.year == 2024), isTrue);
      harness.source.brandGates['Ferrari']!.complete();
      _settle(async);
      expect(harness.cubit.state.results.every((r) => r.year == 2024), isTrue);
      expect(harness.cubit.state.indexStatus?.phase, SearchIndexPhase.ready);
      unawaited(harness.cubit.close());
      _settle(async);
    });
  });

  test('la lista nunca se vacía mientras el índice avanza y se reintenta', () {
    fakeAsync((async) {
      final harness = SearchHarness(groupsByBrand: _catalog);
      harness.source.failuresLeft['Ferrari'] = 1;
      harness.source.failuresLeft['Audi'] = 1;
      final emitted = <SearchState>[];
      harness.cubit.stream.listen(emitted.add);
      harness.cubit.ensureIndex();
      _settle(async, const Duration(milliseconds: 100));
      harness.cubit.onQueryChanged('f');
      harness.cubit.onQueryChanged('fo');
      _settle(async, const Duration(milliseconds: 400));
      expect(harness.cubit.state.results, isNotEmpty);
      final firstNonEmpty = emitted.indexWhere((s) => s.results.isNotEmpty);
      // Desde la primera lista, ninguna actualización la deja vacía.
      expect(
        emitted.skip(firstNonEmpty).where((s) => s.results.isEmpty),
        isEmpty,
      );
      _settle(async, const Duration(minutes: 1));
      expect(
        emitted.skip(firstNonEmpty).where((s) => s.results.isEmpty),
        isEmpty,
      );
      expect(harness.cubit.state.indexStatus?.phase, SearchIndexPhase.ready);
      unawaited(harness.cubit.close());
      _settle(async);
    });
  });
}
