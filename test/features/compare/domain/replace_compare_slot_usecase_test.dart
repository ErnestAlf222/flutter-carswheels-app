import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/compare_test_support.dart';

void main() {
  late InMemoryCompareSelection store;
  late ReplaceCompareSlotUseCase replace;

  setUp(() async {
    store = InMemoryCompareSelection();
    replace = ReplaceCompareSlotUseCase(store);
    await store.write('us', [
      compareSlot(model: 'A'),
      compareSlot(model: 'B'),
      compareSlot(model: 'C'),
    ]);
  });

  test('reemplaza en la misma posición y conserva el orden', () async {
    final result = await replace(
      compareSlot(model: 'B'),
      compareSlot(model: 'Z'),
    );
    expect(result, CompareReplaceResult.replaced);
    expect((await store.read('us')).map((s) => s.modelName), ['A', 'Z', 'C']);
  });

  test('reemplazar el primero y el último respeta la posición', () async {
    await replace(compareSlot(model: 'A'), compareSlot(model: 'X'));
    await replace(compareSlot(model: 'C'), compareSlot(model: 'Y'));
    expect((await store.read('us')).map((s) => s.modelName), ['X', 'B', 'Y']);
  });

  test('un vehículo que ya está en otra posición no se duplica', () async {
    final writes = store.writes;
    final result = await replace(
      compareSlot(model: 'A'),
      compareSlot(model: 'C'),
    );
    expect(result, CompareReplaceResult.alreadyPresent);
    expect(store.writes, writes);
    expect((await store.read('us')).map((s) => s.modelName), ['A', 'B', 'C']);
  });

  test('un vehículo a reemplazar que ya no está no cambia nada', () async {
    final writes = store.writes;
    final result = await replace(
      compareSlot(model: 'Q'),
      compareSlot(model: 'Z'),
    );
    expect(result, CompareReplaceResult.notFound);
    expect(store.writes, writes);
  });

  test('solo toca la lista del mercado del vehículo', () async {
    await store.write('mx', [compareSlot(model: 'M', marketCode: 'mx')]);
    await replace(compareSlot(model: 'A'), compareSlot(model: 'Z'));
    expect((await store.read('mx')).single.modelName, 'M');
  });

  test('con la lista llena, agregar da "lleno" con los 3 actuales', () async {
    final result = await AddToCompareUseCase(store)(compareSlot(model: 'D'));
    expect(result, isA<CompareFull>());
    expect(result.selection.slots.map((s) => s.modelName), ['A', 'B', 'C']);
    expect(result.selection.isFull, isTrue);
  });
}
