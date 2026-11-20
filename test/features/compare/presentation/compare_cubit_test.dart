import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/compare_test_support.dart';

Future<void> _pump() => Future<void>.delayed(Duration.zero);

CompareSelectionEntity _selectionOf(CompareCubit cubit) =>
    (cubit.state as CompareLoaded).selection;

void main() {
  late InMemoryCompareSelection store;
  late FakeCompareMarketSource market;
  late CompareCubit cubit;

  setUp(() {
    store = InMemoryCompareSelection();
    market = FakeCompareMarketSource();
    cubit = buildCompareCubit(
      selection: store,
      market: market,
      noticeDuration: const Duration(milliseconds: 50),
    );
  });

  tearDown(() => cubit.close());

  test('empieza cargando y luego muestra la selección guardada', () async {
    expect(cubit.state, isA<CompareLoading>());
    await _pump();
    expect(cubit.state, isA<CompareLoaded>());
    expect(_selectionOf(cubit).isEmpty, isTrue);
  });

  test('lee lo que ya estaba guardado al arrancar', () async {
    await store.write('us', [compareSlot(model: 'A')]);
    final other = buildCompareCubit(selection: store, market: market);
    await _pump();
    expect((other.state as CompareLoaded).selection.length, 1);
    await other.close();
  });

  test('agregar actualiza la lista y avisa con el nombre', () async {
    await _pump();
    final result = await cubit.add(compareSlot());
    await _pump();
    expect(result, isA<CompareAdded>());
    expect(_selectionOf(cubit).length, 1);
    final state = cubit.state as CompareLoaded;
    expect(state.notice, CompareNotice.added);
    expect(state.noticeSubject, 'Toyota Corolla');
  });

  test('agregar sin anunciar no deja mensaje, ni de lleno', () async {
    await _pump();
    await cubit.add(compareSlot(), announce: false);
    await _pump();
    expect((cubit.state as CompareLoaded).notice, isNull);
    for (final model in ['B', 'C']) {
      await cubit.add(compareSlot(model: model), announce: false);
    }
    await _pump();
    final result = await cubit.add(compareSlot(model: 'D'), announce: false);
    // El resultado "lleno" lleva los 3 vehículos actuales.
    expect(result, isA<CompareFull>());
    expect(result.selection.slots.map((s) => s.modelName), [
      'Corolla',
      'B',
      'C',
    ]);
    expect((cubit.state as CompareLoaded).notice, isNull);
  });

  test('reemplazar cambia por posición y avisa con los dos nombres', () async {
    await _pump();
    for (final model in ['A', 'B', 'C']) {
      await cubit.add(compareSlot(model: model));
    }
    await _pump();
    final result = await cubit.replace(
      compareSlot(model: 'B'),
      compareSlot(model: 'Z', brand: 'Honda'),
    );
    await _pump();
    expect(result, CompareReplaceResult.replaced);
    expect(_selectionOf(cubit).slots.map((s) => s.modelName), ['A', 'Z', 'C']);
    final state = cubit.state as CompareLoaded;
    expect(state.notice, CompareNotice.replaced);
    expect(state.noticeSubject, 'Honda Z');
    expect(state.noticeOther, 'Toyota B');
  });

  test('limpiar y agregar deja solo el nuevo con su mensaje', () async {
    await _pump();
    for (final model in ['A', 'B', 'C']) {
      await cubit.add(compareSlot(model: model));
    }
    await _pump();
    await cubit.clearAndAdd(compareSlot(model: 'Z'));
    await _pump();
    expect(_selectionOf(cubit).slots.map((s) => s.modelName), ['Z']);
    final state = cubit.state as CompareLoaded;
    expect(state.notice, CompareNotice.startedNew);
    expect(state.noticeSubject, 'Toyota Z');
  });

  test('un duplicado deja el mensaje "ya está" y no duplica', () async {
    await _pump();
    await cubit.add(compareSlot());
    await _pump();
    final result = await cubit.add(compareSlot());
    expect(result, isA<CompareAlreadyPresent>());
    final state = cubit.state as CompareLoaded;
    expect(state.notice, CompareNotice.alreadyAdded);
    expect(state.selection.length, 1);
  });

  test('con 3 vehículos, agregar otro deja el mensaje de lleno', () async {
    await _pump();
    for (final model in ['A', 'B', 'C']) {
      await cubit.add(compareSlot(model: model));
    }
    await _pump();
    final result = await cubit.add(compareSlot(model: 'D'));
    expect(result, isA<CompareFull>());
    final state = cubit.state as CompareLoaded;
    expect(state.notice, CompareNotice.full);
    expect(state.selection.length, 3);
  });

  test('cada mensaje nuevo cambia el noticeId', () async {
    await _pump();
    await cubit.add(compareSlot());
    await cubit.add(compareSlot());
    final first = (cubit.state as CompareLoaded).noticeId;
    await cubit.add(compareSlot());
    expect((cubit.state as CompareLoaded).noticeId, first + 1);
  });

  test('el mensaje desaparece solo tras su duración', () async {
    await _pump();
    await cubit.add(compareSlot());
    await cubit.add(compareSlot());
    expect((cubit.state as CompareLoaded).notice, isNotNull);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect((cubit.state as CompareLoaded).notice, isNull);
  });

  test('quitar y limpiar actualizan la lista', () async {
    await _pump();
    await cubit.add(compareSlot(model: 'A'));
    await cubit.add(compareSlot(model: 'B'));
    await _pump();
    await cubit.remove(compareSlot(model: 'A'));
    await _pump();
    expect(_selectionOf(cubit).slots.map((s) => s.modelName), ['B']);
    await cubit.clear();
    await _pump();
    expect(_selectionOf(cubit).isEmpty, isTrue);
  });

  test('cambio de mercado: muestra la selección de ese mercado', () async {
    await store.write('us', [compareSlot(model: 'US')]);
    await store.write('mx', [
      compareSlot(model: 'MX1', marketCode: 'mx'),
      compareSlot(model: 'MX2', marketCode: 'mx'),
    ]);
    await _pump();
    expect(_selectionOf(cubit).length, 1);
    market.switchTo('mx');
    await _pump();
    expect(_selectionOf(cubit).slots.map((s) => s.modelName), ['MX1', 'MX2']);
    market.switchTo('us');
    await _pump();
    expect(_selectionOf(cubit).slots.single.modelName, 'US');
  });

  test('limpiar en un mercado no toca el otro', () async {
    await store.write('us', [compareSlot()]);
    await store.write('mx', [compareSlot(marketCode: 'mx')]);
    await _pump();
    market.switchTo('mx');
    await _pump();
    await cubit.clear();
    await _pump();
    expect(await store.read('us'), hasLength(1));
    expect(await store.read('mx'), isEmpty);
  });
}
