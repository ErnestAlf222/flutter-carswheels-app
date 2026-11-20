import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/compare_test_support.dart';

void main() {
  test('la clave lleva prefijo, versión y mercado', () {
    expect(ComparePayloadMapper.keyFor('us'), 'compare|v1|us');
    expect(ComparePayloadMapper.keyFor('mx'), 'compare|v1|mx');
  });

  test('ida y vuelta conserva el orden y la versión nula', () {
    final slots = [
      compareSlot(model: 'Corolla', versionKey: 'Corolla LE'),
      compareSlot(model: 'Camry'),
      compareSlot(model: 'Civic', brand: 'Honda', year: 2022),
    ];
    final restored = ComparePayloadMapper.fromPayload(
      ComparePayloadMapper.toPayload(slots),
    );
    expect(restored, slots);
    expect(restored[1].versionKey, isNull);
  });

  test('una lista vacía se guarda y se lee vacía', () {
    expect(
      ComparePayloadMapper.fromPayload(
        ComparePayloadMapper.toPayload(const []),
      ),
      isEmpty,
    );
  });

  test('un payload con otra forma lanza para que el lector lo descarte', () {
    expect(
      () => ComparePayloadMapper.fromPayload('{"x":1}'),
      throwsA(anything),
    );
    expect(
      () => ComparePayloadMapper.fromPayload('no es json'),
      throwsA(anything),
    );
  });
}
