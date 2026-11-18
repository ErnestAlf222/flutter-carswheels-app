import 'dart:io';

import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../support/conuee_fixtures.dart';
import '../../../support/isar_test_support.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late IsarMexicoCatalogCacheDatasource datasource;

  setUpAll(() async {
    await IsarTestSupport.prepare();
  });

  setUp(() async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    directory = await Directory.systemTemp.createTemp('isar_mexico_cache');
    isar = await Isar.open(
      [MexicoCatalogCacheModelSchema],
      directory: directory.path,
      name: 'prueba',
      inspector: false,
    );
    datasource = IsarMexicoCatalogCacheDatasource(isar);
  });

  tearDown(() async {
    if (IsarTestSupport.skipReason != null) return;
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  final savedAt = DateTime.fromMillisecondsSinceEpoch(1700000000000);

  test('años: miss, guardar, leer y reemplazar', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    expect(await datasource.readYears('k'), isNull);
    final entry = CachedMxYearsEntity(
      sources: const [MxYearSourceEntity(year: 2025, resourceId: 'a')],
      savedAt: savedAt,
    );
    await datasource.writeYears('k', entry);
    expect(await datasource.readYears('k'), entry);
    final newer = CachedMxYearsEntity(
      sources: const [MxYearSourceEntity(year: 2026, resourceId: 'b')],
      savedAt: savedAt.add(const Duration(days: 1)),
    );
    await datasource.writeYears('k', newer);
    expect(await datasource.readYears('k'), newer);
    expect(await isar.mexicoCatalogCacheModels.count(), 1);
  });

  test('año: guarda y lee las filas limpias', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    final catalog = const MxYearCatalogMapper().toEntity(
      2025,
      conueeFixtureRows,
    );
    final entry = CachedMxYearEntity(catalog: catalog, savedAt: savedAt);
    await datasource.writeYear('v1|year|2025', entry);
    expect(await datasource.readYear('v1|year|2025'), entry);
    expect(await datasource.readYear('v1|year|2026'), isNull);
  });

  test('un payload ilegible cuenta como entrada ausente', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await isar.writeTxn(
      () => isar.mexicoCatalogCacheModels.put(
        MexicoCatalogCacheModel(
          key: 'roto',
          payload: 'no es json',
          savedAtMillis: savedAt.millisecondsSinceEpoch,
        ),
      ),
    );
    expect(await datasource.readYear('roto'), isNull);
    expect(await datasource.readYears('roto'), isNull);
  });
}
