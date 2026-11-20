import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:cars_wheels_app/features/compare/compare.dart';

import '../../../support/compare_test_support.dart';

const CompareVehicleDetailEntity _data = CompareVehicleDetailEntity(
  combinedKmPerLiter: 14.0,
);

Future<void> _settle() async {
  for (int i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late InMemoryCompareSelection store;
  late CompareCubit compare;
  late FakeCompareVehicleSource vehicles;
  late FakeCompareSafetySource safety;
  late CompareTableCubit table;

  setUp(() async {
    store = InMemoryCompareSelection();
    compare = buildCompareCubit(selection: store);
    vehicles = FakeCompareVehicleSource()
      ..details['Corolla'] = _data
      ..details['Camry'] = _data;
    safety = FakeCompareSafetySource()..stars['Corolla'] = 5;
    table = buildCompareTableCubit(
      compare: compare,
      vehicles: vehicles,
      safety: safety,
    );
    await _settle();
  });

  tearDown(() async {
    await table.close();
    await compare.close();
  });

  CompareColumnState columnOf(CompareSlotEntity slot) => table.state.of(slot);

  test('carga cada vehículo de la selección con sus estrellas', () async {
    final corolla = compareSlot(model: 'Corolla');
    await store.write('us', [corolla]);
    await _settle();
    final column = columnOf(corolla) as CompareColumnLoaded;
    expect(column.detail.combinedKmPerLiter, 14.0);
    expect(column.detail.safetyStars, 5);
  });

  test('mientras carga la columna está en cargando', () async {
    final gate = Completer<void>();
    vehicles.gates['Corolla'] = gate;
    final corolla = compareSlot(model: 'Corolla');
    await store.write('us', [corolla]);
    await _settle();
    expect(columnOf(corolla), isA<CompareColumnLoading>());
    gate.complete();
    await _settle();
    expect(columnOf(corolla), isA<CompareColumnLoaded>());
  });

  test(
    'cada columna es independiente: una falla no afecta a la otra',
    () async {
      vehicles.failing.add('Camry');
      final corolla = compareSlot(model: 'Corolla');
      final camry = compareSlot(model: 'Camry');
      await store.write('us', [corolla, camry]);
      await _settle();
      expect(columnOf(corolla), isA<CompareColumnLoaded>());
      expect(columnOf(camry), isA<CompareColumnFailed>());
    },
  );

  test('reintentar vuelve a pedir solo la columna fallida', () async {
    vehicles.failing.add('Camry');
    final corolla = compareSlot(model: 'Corolla');
    final camry = compareSlot(model: 'Camry');
    await store.write('us', [corolla, camry]);
    await _settle();
    vehicles.failing.clear();
    table.retry(corolla);
    table.retry(camry);
    await _settle();
    expect(columnOf(camry), isA<CompareColumnLoaded>());
    // Corolla no falló: no se repitió; Camry se pidió dos veces.
    expect(
      vehicles.requests.where((id) => id.contains('corolla')),
      hasLength(1),
    );
    expect(vehicles.requests.where((id) => id.contains('camry')), hasLength(2));
  });

  test(
    'si NHTSA falla, las estrellas quedan nulas y la columna carga',
    () async {
      safety.failing.add('Corolla');
      final corolla = compareSlot(model: 'Corolla');
      await store.write('us', [corolla]);
      await _settle();
      final column = columnOf(corolla) as CompareColumnLoaded;
      expect(column.detail.safetyStars, isNull);
      expect(column.detail.combinedKmPerLiter, 14.0);
    },
  );

  test('un vehículo sin versiones queda cargado y vacío', () async {
    vehicles.details['Corolla'] = null;
    final corolla = compareSlot(model: 'Corolla');
    await store.write('us', [corolla]);
    await _settle();
    final column = columnOf(corolla) as CompareColumnLoaded;
    expect(column.detail.combinedKmPerLiter, isNull);
  });

  test('lo ya cargado no se repite y lo que sale se descarta', () async {
    final corolla = compareSlot(model: 'Corolla');
    final camry = compareSlot(model: 'Camry');
    await store.write('us', [corolla, camry]);
    await _settle();
    expect(vehicles.requests, hasLength(2));
    await compare.remove(camry);
    await _settle();
    expect(vehicles.requests, hasLength(2));
    expect(table.state.columns.keys, [corolla.identity]);
  });

  test('cambiar la versión es otro vehículo: recarga solo ese', () async {
    final corolla = compareSlot(model: 'Corolla');
    vehicles.details['Corolla|LE'] = const CompareVehicleDetailEntity(
      combinedKmPerLiter: 20.0,
    );
    await store.write('us', [corolla]);
    await _settle();
    await compare.changeVersion(corolla, 'LE');
    await _settle();
    final changed = corolla.withVersion('LE');
    final column = columnOf(changed) as CompareColumnLoaded;
    expect(column.detail.combinedKmPerLiter, 20.0);
    expect(table.state.columns.containsKey(corolla.identity), isFalse);
  });

  test('el resultado de un vehículo que ya salió se ignora', () async {
    final gate = Completer<void>();
    vehicles.gates['Corolla'] = gate;
    final corolla = compareSlot(model: 'Corolla');
    await store.write('us', [corolla]);
    await _settle();
    await compare.remove(corolla);
    await _settle();
    gate.complete();
    await _settle();
    expect(table.state.columns, isEmpty);
  });

  test('cambiar de mercado arma las columnas del nuevo mercado', () async {
    final market = FakeCompareMarketSource();
    final other = buildCompareCubit(selection: store, market: market);
    final mxTable = buildCompareTableCubit(compare: other, vehicles: vehicles);
    final versa = compareSlot(model: 'Versa', marketCode: 'mx');
    vehicles.details['Versa'] = _data;
    await store.write('mx', [versa]);
    await _settle();
    market.switchTo('mx');
    await _settle();
    expect(mxTable.state.of(versa), isA<CompareColumnLoaded>());
    await mxTable.close();
    await other.close();
  });

  test('changeVersion repetida deja el mensaje de "ya está"', () async {
    final first = compareSlot(model: 'Corolla');
    final second = compareSlot(model: 'Corolla', versionKey: 'LE');
    await store.write('us', [first, second]);
    await _settle();
    final result = await compare.changeVersion(first, 'LE');
    await _settle();
    expect(result, CompareVersionUpdateResult.duplicate);
    expect((compare.state as CompareLoaded).notice, CompareNotice.alreadyAdded);
    compare.dismissNotice();
  });
}
