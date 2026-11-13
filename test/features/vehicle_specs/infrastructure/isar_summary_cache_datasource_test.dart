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
      [GroupSummaryCacheModelSchema],
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

  const summary = GroupSummaryEntity(
    vehicleClass: 'Compact Cars',
    minKmPerLiter: 12.5,
    maxKmPerLiter: 16.25,
    hasElectric: true,
    hasPluginHybrid: true,
    hasFuelCell: true,
    variantCount: 4,
  );
  final entry = CachedSummaryEntity(
    summary: summary,
    savedAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
  );

  test('una clave inexistente devuelve nulo', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    expect(await datasource.read('nada'), isNull);
  });

  test('ida y vuelta con todos los campos', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await datasource.write('clave', entry);
    expect(await datasource.read('clave'), entry);
  });

  test('conserva los campos nulos', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    final empty = CachedSummaryEntity(
      summary: const GroupSummaryEntity(
        vehicleClass: null,
        minKmPerLiter: null,
        maxKmPerLiter: null,
        hasElectric: false,
        hasPluginHybrid: false,
        variantCount: 1,
      ),
      savedAt: entry.savedAt,
    );
    await datasource.write('ev', empty);
    expect(await datasource.read('ev'), empty);
  });

  test('escribir una clave existente la reemplaza', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await datasource.write('clave', entry);
    final other = CachedSummaryEntity(
      summary: const GroupSummaryEntity(
        vehicleClass: 'Large Cars',
        minKmPerLiter: null,
        maxKmPerLiter: null,
        hasElectric: true,
        hasPluginHybrid: false,
        variantCount: 2,
      ),
      savedAt: entry.savedAt,
    );
    await datasource.write('clave', other);
    expect(await datasource.read('clave'), other);
    expect(await isar.groupSummaryCacheModels.count(), 1);
  });
}
