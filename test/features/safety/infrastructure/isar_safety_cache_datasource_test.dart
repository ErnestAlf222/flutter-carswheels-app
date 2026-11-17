import 'dart:io';

import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../support/isar_test_support.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late IsarSafetyCacheDatasource datasource;

  setUpAll(() async {
    await IsarTestSupport.prepare();
  });

  setUp(() async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    directory = await Directory.systemTemp.createTemp('isar_safety_cache');
    isar = await Isar.open(
      [
        SafetyRatingsCacheModelSchema,
        RecallsCacheModelSchema,
        SafetyNoMatchCacheModelSchema,
      ],
      directory: directory.path,
      name: 'prueba',
      inspector: false,
    );
    datasource = IsarSafetyCacheDatasource(isar);
  });

  tearDown(() async {
    if (IsarTestSupport.skipReason != null) return;
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  final savedAt = DateTime.fromMillisecondsSinceEpoch(1700000000000);

  test('estrellas: miss, guardar, leer y reemplazar', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    expect(await datasource.readRatings('k'), isNull);
    final entry = CachedGroupSafetyEntity(
      safety: const GroupSafetyEntity(
        ratedCount: 2,
        minOverall: 4,
        maxOverall: 5,
      ),
      savedAt: savedAt,
    );
    await datasource.writeRatings('k', entry);
    expect(await datasource.readRatings('k'), entry);
    final empty = CachedGroupSafetyEntity(
      safety: const GroupSafetyEntity(ratedCount: 0),
      savedAt: savedAt,
    );
    await datasource.writeRatings('k', empty);
    expect(await datasource.readRatings('k'), empty);
    expect(await isar.safetyRatingsCacheModels.count(), 1);
  });

  test('recalls: conserva campos, fecha nula y lista vacía', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    final entry = CachedRecallsEntity(
      summary: RecallSummaryEntity(
        recalls: [
          RecallEntity(
            campaignNumber: '24V128000',
            reportDate: DateTime.utc(2024, 2, 22),
            component: 'SEATS',
            summary: 'Resumen',
            consequence: 'Consecuencia',
            remedy: 'Remedio',
          ),
          const RecallEntity(campaignNumber: '24V999000'),
        ],
      ),
      savedAt: savedAt,
    );
    await datasource.writeRecalls('r', entry);
    expect(await datasource.readRecalls('r'), entry);
    final none = CachedRecallsEntity(
      summary: const RecallSummaryEntity(recalls: []),
      savedAt: savedAt,
    );
    await datasource.writeRecalls('cero', none);
    expect((await datasource.readRecalls('cero'))!.summary.count, 0);
  });

  test('no emparejado: miss y guardar', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    expect(await datasource.readNoMatch('n'), isNull);
    await datasource.writeNoMatch('n', savedAt);
    expect(await datasource.readNoMatch('n'), savedAt);
  });
}
