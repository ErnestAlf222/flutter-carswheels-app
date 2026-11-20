import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/search_test_support.dart';

void main() {
  _emptyBrandTests();
  late FakeSearchCatalogSource source;
  late SearchIndexStore store;
  late BuildSearchIndexUseCase build;
  late SearchCatalogUseCase search;

  setUp(() {
    source = FakeSearchCatalogSource({
      for (final i in List.generate(10, (i) => i))
        'Marca$i': ['Modelo$i', 'Otro$i'],
    });
    store = SearchIndexStore();
    build = BuildSearchIndexUseCase(
      source: source,
      store: store,
      sortStrategy: postingSort,
    );
    search = SearchCatalogUseCase(
      store: store,
      ranker: const SearchResultRanker(sortStrategy: rankedSort),
    );
  });

  test('emite progreso, termina listo y el índice busca grupos', () async {
    final statuses = await build(usScope).toList();
    expect(statuses.first.phase, SearchIndexPhase.building);
    expect(statuses.first.completedBrands, 0);
    expect(statuses.first.totalBrands, 10);
    final progress = [for (final s in statuses) s.completedBrands];
    expect(progress, orderedEquals([...progress]..sort()));
    expect(statuses.last.phase, SearchIndexPhase.ready);
    expect(statuses.last.progress, 1);
    expect(search(usScope, 'modelo3').single.groupName, 'Modelo3');
    // Cada grupo conserva las variantes que entregó el origen.
    expect(search(usScope, 'modelo3').single.variantNames, ['Modelo3']);
  });

  test('las marcas son buscables antes de tener los grupos', () async {
    source.gate = Completer<void>();
    final statuses = StreamIterator(build(usScope));
    await statuses.moveNext();
    expect(statuses.current.phase, SearchIndexPhase.building);
    // La marca ya está en el índice (como fila sola); la búsqueda solo da grupos.
    final record = store.recordOf(usScope.key)!;
    expect(record.index.match(['marca3']).single.groupName, isNull);
    expect(search(usScope, 'marca3'), isEmpty);
    expect(search(usScope, 'modelo3'), isEmpty);
    source.gate!.complete();
    while (await statuses.moveNext()) {}
    expect(search(usScope, 'modelo3'), hasLength(1));
  });

  test('la concurrencia no pasa del límite de config', () async {
    source.gate = Completer<void>();
    final done = build(usScope).drain<void>();
    await Future<void>.delayed(Duration.zero);
    expect(source.maxInFlight, SearchConfig.indexBuildConcurrency);
    source.gate!.complete();
    await done;
    expect(source.maxInFlight, SearchConfig.indexBuildConcurrency);
    expect(source.groupRequests, hasLength(10));
  });

  test('una segunda construcción del mismo alcance no pide nada', () async {
    await build(usScope).drain<void>();
    final requests = source.groupRequests.length;
    final again = await build(usScope).toList();
    expect(again.single.phase, SearchIndexPhase.ready);
    expect(source.brandRequests, 1);
    expect(source.groupRequests, hasLength(requests));
  });

  test('cambiar de mercado cancela y descarta el índice incompleto', () async {
    source.gate = Completer<void>();
    final first = <SearchIndexStatusEntity>[];
    final firstDone = build(usScope).forEach(first.add);
    await Future<void>.delayed(Duration.zero);
    final second = build(mxScope).drain<void>();
    source.gate!.complete();
    await firstDone;
    await second;
    expect(first.every((s) => s.phase == SearchIndexPhase.building), isTrue);
    expect(store.recordOf(usScope.key), isNull);
    expect(store.recordOf(mxScope.key)!.status.phase, SearchIndexPhase.ready);
    expect(search(usScope, 'modelo1'), isEmpty);
    expect(source.scopes.map((s) => s.marketCode), ['us', 'mx']);
  });

  test('cambiar de año cancela la construcción anterior', () async {
    source.gate = Completer<void>();
    final firstDone = build(usScope).drain<void>();
    await Future<void>.delayed(Duration.zero);
    const otherYear = SearchScopeEntity(marketCode: 'us', year: 2024);
    final second = build(otherYear).drain<void>();
    source.gate!.complete();
    await firstDone;
    await second;
    expect(store.recordOf(usScope.key), isNull);
    expect(store.recordOf(otherYear.key)!.status.phase, SearchIndexPhase.ready);
  });

  test('dejar de escuchar el flujo cancela la construcción', () async {
    source.gate = Completer<void>();
    final subscription = build(usScope).listen((_) {});
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    source.gate!.complete();
    await Future<void>.delayed(Duration.zero);
    expect(store.recordOf(usScope.key), isNull);
  });

  test('una marca fallida deja el índice parcial y las demás siguen', () async {
    source.failingBrands.add('Marca2');
    final statuses = await build(usScope).toList();
    final last = statuses.last;
    expect(last.phase, SearchIndexPhase.partial);
    expect(last.failedBrands, ['Marca2']);
    expect(search(usScope, 'modelo5'), hasLength(1));
    expect(search(usScope, 'modelo2'), isEmpty);
    // La marca fallida queda en el índice, sin grupos.
    final entries = store.recordOf(usScope.key)!.index.match(['marca2']);
    expect(entries.single.groupName, isNull);
    expect(search(usScope, 'marca2'), isEmpty);
  });

  test('sin reintento, un índice parcial no vuelve a pedir nada', () async {
    source.failingBrands.add('Marca2');
    await build(usScope).drain<void>();
    final requests = source.groupRequests.length;
    final again = await build(usScope).toList();
    expect(again.single.phase, SearchIndexPhase.partial);
    expect(source.groupRequests, hasLength(requests));
  });

  test('el reintento pide solo las marcas fallidas', () async {
    source
      ..failingBrands.add('Marca2')
      ..failingBrands.add('Marca7');
    await build(usScope).drain<void>();
    source.groupRequests.clear();
    source.failingBrands.remove('Marca2');
    final statuses = await build(usScope, retryFailedOnly: true).toList();
    expect(source.groupRequests.toSet(), {'Marca2', 'Marca7'});
    expect(source.brandRequests, 1);
    expect(statuses.last.phase, SearchIndexPhase.partial);
    expect(statuses.last.failedBrands, ['Marca7']);
    expect(search(usScope, 'modelo2'), hasLength(1));
    // Sin duplicar las filas de las marcas que ya estaban.
    expect(search(usScope, 'modelo5'), hasLength(1));
    source.failingBrands.clear();
    final done = await build(usScope, retryFailedOnly: true).toList();
    expect(done.last.phase, SearchIndexPhase.ready);
    expect(search(usScope, 'modelo7'), hasLength(1));
  });

  test('si falla la lista de marcas el flujo termina con error', () async {
    final failing = BuildSearchIndexUseCase(
      source: _BrandlessSource(),
      store: store,
      sortStrategy: postingSort,
    );
    await expectLater(failing(usScope), emitsError(isA<StateError>()));
    expect(store.recordOf(usScope.key), isNull);
  });
}

class _BrandlessSource implements SearchCatalogSource {
  @override
  Future<List<String>> fetchBrands(SearchScopeEntity scope) async =>
      throw StateError('sin red');

  @override
  Future<List<SearchGroupEntity>> fetchGroups(
    SearchScopeEntity scope,
    String brand,
  ) async => const [];
}

void _emptyBrandTests() {
  late FakeSearchCatalogSource source;
  late SearchIndexStore store;
  late BuildSearchIndexUseCase build;

  setUp(() {
    source = FakeSearchCatalogSource({
      for (final i in List.generate(4, (i) => i)) 'Marca$i': ['Modelo$i'],
    });
    store = SearchIndexStore();
    build = BuildSearchIndexUseCase(
      source: source,
      store: store,
      sortStrategy: postingSort,
    );
  });

  group('marca vacía', () {
    test(
      'una respuesta vacía aislada queda pendiente, no confirmada',
      () async {
        source.emptyBrands.add('Marca1');
        final last = (await build(usScope).toList()).last;
        expect(last.phase, SearchIndexPhase.partial);
        expect(last.failedBrands, ['Marca1']);
        expect(last.emptyBrands, isEmpty);
      },
    );

    test(
      'vacía de forma consistente: se confirma y el índice queda listo',
      () async {
        source.emptyBrands.add('Marca1');
        await build(usScope).drain<void>();
        final retry = (await build(
          usScope,
          retryFailedOnly: true,
        ).toList()).last;
        expect(retry.phase, SearchIndexPhase.ready);
        expect(retry.failedBrands, isEmpty);
        expect(retry.emptyBrands, ['Marca1']);
        expect(retry.indexedBrands, retry.totalBrands);
        expect(store.recordOf(usScope.key)!.isConsistent, isTrue);
        // Ya listo: otra construcción no pide nada.
        source.groupRequests.clear();
        await build(usScope, retryFailedOnly: true).drain<void>();
        expect(source.groupRequests, isEmpty);
      },
    );

    test('un error entre dos vacías reinicia la cuenta', () async {
      source.emptyBrands.add('Marca1');
      await build(usScope).drain<void>();
      source.failingBrands.add('Marca1');
      final failed = (await build(
        usScope,
        retryFailedOnly: true,
      ).toList()).last;
      expect(failed.phase, SearchIndexPhase.partial);
      expect(failed.emptyBrands, isEmpty);
      source.failingBrands.clear();
      final again = (await build(usScope, retryFailedOnly: true).toList()).last;
      expect(again.phase, SearchIndexPhase.partial);
      final last = (await build(usScope, retryFailedOnly: true).toList()).last;
      expect(last.phase, SearchIndexPhase.ready);
    });

    test('una marca con error sigue parcial y se reintenta', () async {
      source.failingBrands.add('Marca2');
      for (int round = 0; round < 3; round++) {
        final last = (await build(
          usScope,
          retryFailedOnly: true,
        ).toList()).last;
        expect(last.phase, SearchIndexPhase.partial);
        expect(last.failedBrands, ['Marca2']);
        expect(last.emptyBrands, isEmpty);
      }
      expect(source.groupRequests.where((b) => b == 'Marca2'), hasLength(3));
    });

    test('falla primero y luego responde con modelos: converge', () async {
      source.failuresLeft['Marca2'] = 1;
      final first = (await build(usScope).toList()).last;
      expect(first.phase, SearchIndexPhase.partial);
      final last = (await build(usScope, retryFailedOnly: true).toList()).last;
      expect(last.phase, SearchIndexPhase.ready);
      expect(last.emptyBrands, isEmpty);
      final record = store.recordOf(usScope.key)!;
      expect(record.index.match(['modelo2']), hasLength(1));
    });
  });
}
