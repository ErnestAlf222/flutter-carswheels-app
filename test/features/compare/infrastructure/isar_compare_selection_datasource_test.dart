import 'dart:io';

import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../support/compare_test_support.dart';
import '../../../support/isar_test_support.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late IsarCompareSelectionDatasource datasource;

  setUpAll(() async {
    await IsarTestSupport.prepare();
  });

  setUp(() async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    directory = await Directory.systemTemp.createTemp('isar_compare');
    isar = await Isar.open(
      [CompareSelectionModelSchema],
      directory: directory.path,
      name: 'prueba',
      inspector: false,
    );
    datasource = IsarCompareSelectionDatasource(isar, clock: DateTime.now);
  });

  tearDown(() async {
    if (IsarTestSupport.skipReason != null) return;
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  test('guarda por mercado, conserva el orden y reemplaza la fila', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    expect(await datasource.read('us'), isEmpty);
    final us = [compareSlot(model: 'A'), compareSlot(model: 'B')];
    await datasource.write('us', us);
    await datasource.write('mx', [compareSlot(model: 'M', marketCode: 'mx')]);
    expect(await datasource.read('us'), us);
    expect((await datasource.read('mx')).single.modelName, 'M');
    await datasource.write('us', [compareSlot(model: 'C')]);
    expect((await datasource.read('us')).single.modelName, 'C');
    // Una fila por mercado: reemplazar no acumula.
    expect(await isar.compareSelectionModels.count(), 2);
  });

  test('sobrevive al reinicio: se reabre la base y sigue ahí', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await datasource.write('us', [compareSlot(versionKey: 'LE')]);
    await isar.close();
    isar = await Isar.open(
      [CompareSelectionModelSchema],
      directory: directory.path,
      name: 'prueba',
      inspector: false,
    );
    datasource = IsarCompareSelectionDatasource(isar, clock: DateTime.now);
    expect((await datasource.read('us')).single.versionKey, 'LE');
  });

  test('un payload ilegible cuenta como selección vacía', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await isar.writeTxn(
      () => isar.compareSelectionModels.putByKey(
        CompareSelectionModel(
          key: ComparePayloadMapper.keyFor('us'),
          payload: 'roto',
          savedAtMillis: 0,
        ),
      ),
    );
    expect(await datasource.read('us'), isEmpty);
  });

  test('una versión de clave distinta no se lee', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await isar.writeTxn(
      () => isar.compareSelectionModels.putByKey(
        CompareSelectionModel(
          key: 'compare|v0|us',
          payload: ComparePayloadMapper.toPayload([compareSlot()]),
          savedAtMillis: 0,
        ),
      ),
    );
    expect(await datasource.read('us'), isEmpty);
  });

  test('watch emite la lista actual y cada escritura', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    final lengths = <int>[];
    final subscription = datasource
        .watch('us')
        .listen((slots) => lengths.add(slots.length));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await datasource.write('us', [compareSlot()]);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await subscription.cancel();
    expect(lengths.first, 0);
    expect(lengths.last, 1);
  });
}
