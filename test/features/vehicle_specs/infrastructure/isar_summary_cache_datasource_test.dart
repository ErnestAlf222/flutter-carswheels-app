import 'dart:io';

import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../support/isar_test_support.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late IsarSummaryCacheDatasource datasource;

  setUpAll(() async {
    await IsarTestSupport.prepare();
  });

  setUp(() async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    directory = await Directory.systemTemp.createTemp('isar_summary_cache');
    isar = await Isar.open(
      [ModelSummaryCacheModelSchema],
      directory: directory.path,
      name: 'prueba',
      inspector: false,
    );
    datasource = IsarSummaryCacheDatasource(isar);
  });

  tearDown(() async {
    if (IsarTestSupport.skipReason != null) return;
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  final entry = CachedSummaryEntity(
    summary: const ModelSummaryEntity(
      vehicleClass: 'Compact Cars',
      powertrain: Powertrain.combustion,
      combinedKmPerLiter: 14.5,
    ),
    savedAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
  );

  test('una clave inexistente devuelve nulo', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    expect(await datasource.read('nada'), isNull);
  });

  test('escribe y lee una entrada', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await datasource.write('clave', entry);
    expect(await datasource.read('clave'), entry);
  });

  test('conserva los campos nulos', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    final electric = CachedSummaryEntity(
      summary: const ModelSummaryEntity(
        vehicleClass: null,
        powertrain: Powertrain.electric,
        combinedKmPerLiter: null,
      ),
      savedAt: entry.savedAt,
    );
    await datasource.write('ev', electric);
    expect(await datasource.read('ev'), electric);
  });

  test('escribir una clave existente la reemplaza', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await datasource.write('clave', entry);
    final other = CachedSummaryEntity(
      summary: const ModelSummaryEntity(
        vehicleClass: 'Large Cars',
        powertrain: Powertrain.other,
        combinedKmPerLiter: null,
      ),
      savedAt: entry.savedAt,
    );
    await datasource.write('clave', other);
    expect(await datasource.read('clave'), other);
    expect(await isar.modelSummaryCacheModels.count(), 1);
  });
}
