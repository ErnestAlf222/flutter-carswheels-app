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

SearchResultEntity _result(String group, {String brand = 'Toyota'}) =>
    SearchResultEntity(
      brand: brand,
      groupName: group,
      year: 2025,
      marketCode: 'us',
    );

void _settle(FakeAsync async, [Duration time = const Duration(seconds: 1)]) {
  async.flushMicrotasks();
  async.elapse(time);
  async.flushMicrotasks();
}

void _run(SearchHarness harness, void Function(FakeAsync async) body) {
  fakeAsync((async) {
    body(async);
    unawaited(harness.cubit.close());
    _settle(async);
  });
}

// Busca "sport" sin alcance de marca: cinco resultados de tres marcas.
SearchHarness _sportHarness({
  int concurrency = SearchConfig.analysisConcurrency,
}) {
  final harness = SearchHarness(
    groupsByBrand: {
      'Toyota': ['Camry Sport', 'Prius Sport'],
      'Honda': ['Civic Sport', 'Accord Sport'],
      'Hyundai': ['Ioniq Sport'],
    },
    analysisConcurrency: concurrency,
  );
  harness.traits.byGroup.addAll({
    'Camry Sport': const SearchResultTraitsEntity(
      engines: {SearchEngineOption.combustion},
      maxKmPerLiter: 14,
    ),
    'Prius Sport': const SearchResultTraitsEntity(
      engines: {SearchEngineOption.hybrid},
      maxKmPerLiter: 25,
    ),
    'Ioniq Sport': const SearchResultTraitsEntity(
      engines: {SearchEngineOption.electric},
    ),
  });
  return harness;
}

void _search(SearchHarness harness, FakeAsync async, [String text = 'sport']) {
  harness.cubit.ensureIndex();
  _settle(async);
  harness.cubit.onQueryChanged(text);
  _settle(async);
}

void main() {
  group('corredor de análisis', () {
    SearchResultEntity named(int index) => _result('G$index');
    List<SearchResultEntity> results(int count) => List.generate(count, named);

    test('respeta la concurrencia máxima y analiza todo', () {
      fakeAsync((async) {
        final source = FakeSearchTraitsSource();
        final gate = source.gate = Completer<void>();
        final runner = SearchAnalysisRunner(source: source, maxConcurrent: 4);
        final updates = <SearchTraitsUpdate>[];
        final done = <bool>[];
        runner
            .run(results(10))
            .listen(updates.add, onDone: () => done.add(true));
        async.flushMicrotasks();
        expect(source.inFlight, 4);
        gate.complete();
        _settle(async);
        expect(source.maxInFlight, 4);
        expect(source.requests, hasLength(10));
        expect(updates, hasLength(10));
        expect(done, [true]);
      });
    });

    test('respeta el tope de resultados', () {
      fakeAsync((async) {
        final source = FakeSearchTraitsSource();
        final runner = SearchAnalysisRunner(
          source: source,
          maxConcurrent: 4,
          maxResults: 3,
        );
        runner.run(results(10)).listen((_) {});
        _settle(async);
        expect(source.requests, ['G0', 'G1', 'G2']);
      });
    });

    test('cancelar detiene los pedidos que no empezaron', () {
      fakeAsync((async) {
        final source = FakeSearchTraitsSource();
        final gate = source.gate = Completer<void>();
        final runner = SearchAnalysisRunner(source: source, maxConcurrent: 2);
        final updates = <SearchTraitsUpdate>[];
        final subscription = runner.run(results(6)).listen(updates.add);
        async.flushMicrotasks();
        expect(source.requests, hasLength(2));
        unawaited(subscription.cancel());
        gate.complete();
        _settle(async);
        expect(source.requests, hasLength(2));
        expect(updates, isEmpty);
      });
    });

    test('un resultado que falla se omite y el resto sigue', () {
      fakeAsync((async) {
        final source = FakeSearchTraitsSource()..failing.add('G1');
        final runner = SearchAnalysisRunner(source: source, maxConcurrent: 1);
        final updates = <SearchTraitsUpdate>[];
        runner.run(results(3)).listen(updates.add);
        _settle(async);
        expect(
          [for (final update in updates) update.result.groupName],
          ['G0', 'G2'],
        );
      });
    });
  });

  group('análisis bajo demanda en el cubit', () {
    test('sin hoja ni filtros nunca se piden rasgos', () {
      final harness = _sportHarness();
      _run(harness, (async) {
        _search(harness, async);
        expect(harness.cubit.state.totalResults, 5);
        expect(harness.traits.requests, isEmpty);
        expect(harness.cubit.state.isAnalyzing, isFalse);
        // Un filtro de marca (sin necesidad de rasgos) tampoco los pide.
        harness.cubit.toggleBrandFilter('Toyota');
        _settle(async);
        expect(harness.traits.requests, isEmpty);
      });
    });

    test(
      'al abrir la hoja analiza lo que falta, con progreso y concurrencia',
      () {
        final harness = _sportHarness(concurrency: 2);
        _run(harness, (async) {
          _search(harness, async);
          final gate = harness.traits.gate = Completer<void>();
          harness.cubit.filtersSheetOpened();
          async.flushMicrotasks();
          expect(harness.cubit.state.isAnalyzing, isTrue);
          expect(harness.cubit.state.analyzedCount, 0);
          expect(harness.cubit.state.analysisCandidates, hasLength(5));
          gate.complete();
          _settle(async);
          expect(harness.cubit.state.isAnalyzing, isFalse);
          expect(harness.cubit.state.analyzedCount, 5);
          expect(harness.traits.maxInFlight, 2);
          expect(harness.traits.requests, hasLength(5));
        });
      },
    );

    test('no repite lo ya analizado al reabrir la hoja', () {
      final harness = _sportHarness();
      _run(harness, (async) {
        _search(harness, async);
        harness.cubit.filtersSheetOpened();
        _settle(async);
        expect(harness.traits.requests, hasLength(5));
        harness.cubit.filtersSheetClosed();
        harness.cubit.filtersSheetOpened();
        _settle(async);
        expect(harness.traits.requests, hasLength(5));
      });
    });

    test('al cerrar la hoja sin filtros se cancela el análisis', () {
      final harness = _sportHarness(concurrency: 1);
      _run(harness, (async) {
        _search(harness, async);
        harness.traits.gate = Completer<void>();
        harness.cubit.filtersSheetOpened();
        async.flushMicrotasks();
        expect(harness.cubit.state.isAnalyzing, isTrue);
        harness.cubit.filtersSheetClosed();
        expect(harness.cubit.state.isAnalyzing, isFalse);
        harness.traits.gate!.complete();
        _settle(async);
        // Solo salió el pedido que ya estaba en curso.
        expect(harness.traits.requests, hasLength(1));
        expect(harness.cubit.state.traits, isEmpty);
      });
    });

    test(
      'con un filtro de motorización el análisis sigue al cerrar la hoja',
      () {
        final harness = _sportHarness();
        _run(harness, (async) {
          _search(harness, async);
          final gate = harness.traits.gate = Completer<void>();
          harness.cubit.filtersSheetOpened();
          harness.cubit.toggleEngine(SearchEngineOption.hybrid);
          harness.cubit.filtersSheetClosed();
          async.flushMicrotasks();
          expect(harness.cubit.state.isAnalyzing, isTrue);
          gate.complete();
          _settle(async);
          expect(harness.cubit.state.analyzedCount, 5);
        });
      },
    );

    test('cambiar la consulta cancela el análisis en curso', () {
      final harness = _sportHarness(concurrency: 1);
      _run(harness, (async) {
        _search(harness, async);
        harness.traits.gate = Completer<void>();
        harness.cubit.filtersSheetOpened();
        async.flushMicrotasks();
        expect(harness.cubit.state.isAnalyzing, isTrue);
        harness.cubit.onQueryChanged('sport x');
        expect(harness.cubit.state.isAnalyzing, isFalse);
        harness.traits.gate!.complete();
        _settle(async);
        expect(harness.traits.requests, hasLength(1));
      });
    });

    test('cambiar mercado o año cancela, y limpia filtros y rasgos', () {
      final harness = _sportHarness(concurrency: 1);
      _run(harness, (async) {
        _search(harness, async);
        final gate = harness.traits.gate = Completer<void>();
        harness.cubit.toggleEngine(SearchEngineOption.electric);
        async.flushMicrotasks();
        expect(harness.cubit.state.isAnalyzing, isTrue);
        harness.context.change(_usScope2026);
        async.flushMicrotasks();
        final state = harness.cubit.state;
        expect(state.isAnalyzing, isFalse);
        expect(state.filters, SearchFiltersEntity.none);
        expect(state.traits, isEmpty);
        gate.complete();
        _settle(async);
        // Solo salió el pedido que ya estaba en curso.
        expect(harness.traits.requests, hasLength(1));
        expect(harness.cubit.state.traits, isEmpty);
      });
    });

    test('con filtros activos los resultados nuevos se analizan solos', () {
      final harness = _sportHarness();
      _run(harness, (async) {
        _search(harness, async);
        harness.cubit.toggleEngine(SearchEngineOption.hybrid);
        _settle(async);
        expect(harness.traits.requests, hasLength(5));
        harness.cubit.onQueryChanged('ioniq');
        _settle(async);
        // Ioniq ya estaba analizado: no se vuelve a pedir.
        expect(harness.traits.requests, hasLength(5));
        harness.cubit.onQueryChanged('civic');
        _settle(async);
        expect(harness.traits.requests, hasLength(5));
        expect(harness.cubit.state.analyzedCount, 1);
      });
    });

    test('los filtros se conservan al editar el texto', () {
      final harness = _sportHarness();
      _run(harness, (async) {
        _search(harness, async);
        harness.cubit.toggleBrandFilter('Honda');
        harness.cubit.setSortOrder(SearchSortOrder.alphabetical);
        harness.cubit.onQueryChanged('sport s');
        _settle(async);
        expect(harness.cubit.state.filters.brands, {'Honda'});
        expect(harness.cubit.state.filters.sort, SearchSortOrder.alphabetical);
        harness.cubit.clearFilters();
        expect(harness.cubit.state.filters, SearchFiltersEntity.none);
      });
    });

    test('tocar el orden elegido vuelve al orden original', () {
      final harness = _sportHarness();
      _run(harness, (async) {
        harness.cubit.setSortOrder(SearchSortOrder.mostEfficient);
        expect(harness.cubit.state.filters.sort, SearchSortOrder.mostEfficient);
        harness.cubit.setSortOrder(SearchSortOrder.mostEfficient);
        expect(harness.cubit.state.filters.sort, SearchSortOrder.relevance);
      });
    });

    test('un pedido fallido deja el resultado sin analizar', () {
      final harness = _sportHarness();
      harness.traits.failing.add('Civic Sport');
      _run(harness, (async) {
        _search(harness, async);
        harness.cubit.filtersSheetOpened();
        _settle(async);
        expect(harness.cubit.state.isAnalyzing, isFalse);
        expect(harness.cubit.state.analyzedCount, 4);
      });
    });
  });
}
