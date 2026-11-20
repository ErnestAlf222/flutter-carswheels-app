import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/compare_test_support.dart';

void main() {
  late InMemoryCompareSelection store;
  late AddToCompareUseCase add;

  setUp(() {
    store = InMemoryCompareSelection();
    add = AddToCompareUseCase(store);
  });

  group('límites de la configuración', () {
    test('caben 3 y hacen falta 2 para comparar', () {
      expect(CompareConfig.maxSlots, 3);
      expect(CompareConfig.minSlots, 2);
    });

    test('canCompare e isFull siguen los límites', () {
      final one = CompareSelectionEntity([compareSlot()]);
      final two = CompareSelectionEntity([
        compareSlot(),
        compareSlot(model: 'Camry'),
      ]);
      final three = CompareSelectionEntity([
        compareSlot(),
        compareSlot(model: 'Camry'),
        compareSlot(model: 'RAV4'),
      ]);
      expect(
        [one.canCompare, two.canCompare, three.canCompare],
        [false, true, true],
      );
      expect([one.isFull, two.isFull, three.isFull], [false, false, true]);
      expect(CompareSelectionEntity.empty.isEmpty, isTrue);
    });
  });

  group('AddToCompare', () {
    test('agrega al final y conserva el orden', () async {
      await add(compareSlot(model: 'Corolla'));
      final result = await add(compareSlot(model: 'Camry'));
      expect(result, isA<CompareAdded>());
      expect(result.selection.slots.map((s) => s.modelName), [
        'Corolla',
        'Camry',
      ]);
      expect((await store.read('us')).map((s) => s.modelName), [
        'Corolla',
        'Camry',
      ]);
    });

    test('rechaza el mismo grupo, versión y año sin escribir', () async {
      await add(compareSlot(versionKey: 'Corolla LE'));
      final writes = store.writes;
      final result = await add(compareSlot(versionKey: 'Corolla LE'));
      expect(result, isA<CompareAlreadyPresent>());
      expect(result.selection.length, 1);
      expect(store.writes, writes);
    });

    test('otra versión, otro año u otra marca no es duplicado', () async {
      await add(compareSlot(versionKey: 'Corolla LE'));
      final results = [
        await add(compareSlot(versionKey: 'Corolla SE')),
        await add(compareSlot(year: 2023)),
      ];
      expect(results, everyElement(isA<CompareAdded>()));
      expect((await store.read('us')).length, 3);
    });

    test('sin versión y con versión son vehículos distintos', () async {
      await add(compareSlot());
      final result = await add(compareSlot(versionKey: 'Corolla LE'));
      expect(result, isA<CompareAdded>());
    });

    test('con 3 vehículos devuelve lleno y no cambia lo guardado', () async {
      await add(compareSlot(model: 'A'));
      await add(compareSlot(model: 'B'));
      await add(compareSlot(model: 'C'));
      final writes = store.writes;
      final result = await add(compareSlot(model: 'D'));
      expect(result, isA<CompareFull>());
      expect(result.selection.length, CompareConfig.maxSlots);
      expect(store.writes, writes);
    });

    test('un duplicado con la lista llena cuenta como "ya está"', () async {
      await add(compareSlot(model: 'A'));
      await add(compareSlot(model: 'B'));
      await add(compareSlot(model: 'C'));
      expect(await add(compareSlot(model: 'B')), isA<CompareAlreadyPresent>());
    });

    test('cada mercado tiene su propia lista', () async {
      await add(compareSlot(marketCode: 'us'));
      final mx = await add(compareSlot(marketCode: 'mx'));
      expect(mx, isA<CompareAdded>());
      expect((await store.read('us')).length, 1);
      expect((await store.read('mx')).length, 1);
    });
  });

  group('RemoveFromCompare y ClearCompare', () {
    test('quita solo ese vehículo y mantiene el orden', () async {
      await add(compareSlot(model: 'A'));
      await add(compareSlot(model: 'B'));
      await add(compareSlot(model: 'C'));
      await RemoveFromCompareUseCase(store)(compareSlot(model: 'B'));
      expect((await store.read('us')).map((s) => s.modelName), ['A', 'C']);
    });

    test('quitar uno que no está no escribe', () async {
      await add(compareSlot(model: 'A'));
      final writes = store.writes;
      await RemoveFromCompareUseCase(store)(compareSlot(model: 'Z'));
      expect(store.writes, writes);
    });

    test('limpiar vacía solo el mercado indicado', () async {
      await add(compareSlot(marketCode: 'us'));
      await add(compareSlot(marketCode: 'mx'));
      await ClearCompareUseCase(store)('us');
      expect(await store.read('us'), isEmpty);
      expect((await store.read('mx')).length, 1);
    });
  });

  test('ObserveCompareSelection emite la actual y cada cambio', () async {
    final observe = ObserveCompareSelectionUseCase(store);
    final lengths = <int>[];
    final subscription = observe('us')
        .listen((selection) => lengths.add(selection.length));
    await Future<void>.delayed(Duration.zero);
    await add(compareSlot(model: 'A'));
    await add(compareSlot(model: 'B'));
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    expect(lengths, [0, 1, 2]);
  });
}
