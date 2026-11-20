import 'package:flutter_test/flutter_test.dart';

import 'package:cars_wheels_app/features/compare/compare.dart';

import '../../../support/compare_test_support.dart';

void main() {
  late InMemoryCompareSelection store;
  late UpdateCompareSlotVersionUseCase useCase;

  setUp(() {
    store = InMemoryCompareSelection();
    useCase = UpdateCompareSlotVersionUseCase(store);
  });

  test('guarda la versión elegida y conserva la posición', () async {
    final camry = compareSlot(model: 'Camry');
    final corolla = compareSlot(model: 'Corolla');
    final prius = compareSlot(model: 'Prius');
    await store.write('us', [camry, corolla, prius]);

    final result = await useCase(corolla, 'Corolla LE');

    expect(result, CompareVersionUpdateResult.updated);
    final saved = await store.read('us');
    expect(saved.map((slot) => slot.modelName), ['Camry', 'Corolla', 'Prius']);
    expect(saved[1].versionKey, 'Corolla LE');
    expect(saved[0].versionKey, isNull);
    expect(saved[2].versionKey, isNull);
  });

  test('con nulo vuelve a la versión predeterminada', () async {
    final slot = compareSlot(versionKey: 'Corolla LE');
    await store.write('us', [slot]);

    final result = await useCase(slot, null);

    expect(result, CompareVersionUpdateResult.updated);
    expect((await store.read('us')).single.versionKey, isNull);
  });

  test('la misma versión no escribe nada', () async {
    final slot = compareSlot(versionKey: 'Corolla LE');
    await store.write('us', [slot]);
    final writesBefore = store.writes;

    final result = await useCase(slot, 'Corolla LE');

    expect(result, CompareVersionUpdateResult.unchanged);
    expect(store.writes, writesBefore);
  });

  test('un vehículo que ya no está no cambia nada', () async {
    await store.write('us', [compareSlot(model: 'Camry')]);
    final writesBefore = store.writes;

    final result = await useCase(compareSlot(model: 'Corolla'), 'LE');

    expect(result, CompareVersionUpdateResult.unchanged);
    expect(store.writes, writesBefore);
  });

  test('rechaza una versión que dejaría dos vehículos idénticos', () async {
    final first = compareSlot();
    final second = compareSlot(versionKey: 'Corolla LE');
    await store.write('us', [first, second]);
    final writesBefore = store.writes;

    final result = await useCase(first, 'Corolla LE');

    expect(result, CompareVersionUpdateResult.duplicate);
    expect(store.writes, writesBefore);
    expect((await store.read('us')).map((slot) => slot.versionKey), [
      null,
      'Corolla LE',
    ]);
  });

  test('solo toca la lista de su mercado', () async {
    final us = compareSlot();
    final mx = compareSlot(marketCode: 'mx');
    await store.write('us', [us]);
    await store.write('mx', [mx]);

    await useCase(us, 'LE');

    expect((await store.read('mx')).single.versionKey, isNull);
  });
}
