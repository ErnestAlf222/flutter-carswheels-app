import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryCache implements SafetyCacheDatasource {
  final Map<String, CachedGroupSafetyEntity> ratings = {};
  final Map<String, CachedRecallsEntity> recalls = {};
  final Map<String, DateTime> noMatch = {};

  @override
  Future<CachedGroupSafetyEntity?> readRatings(String key) async =>
      ratings[key];

  @override
  Future<void> writeRatings(String key, CachedGroupSafetyEntity entry) async =>
      ratings[key] = entry;

  @override
  Future<CachedRecallsEntity?> readRecalls(String key) async => recalls[key];

  @override
  Future<void> writeRecalls(String key, CachedRecallsEntity entry) async =>
      recalls[key] = entry;

  @override
  Future<DateTime?> readNoMatch(String key) async => noMatch[key];

  @override
  Future<void> writeNoMatch(String key, DateTime savedAt) async =>
      noMatch[key] = savedAt;
}

class _FakeRatings implements SafetyRatingsRepository {
  GroupSafetyEntity? result = const GroupSafetyEntity(
    ratedCount: 1,
    minOverall: 5,
    maxOverall: 5,
  );
  AppFailure? failure;
  int calls = 0;

  @override
  Future<GroupSafetyEntity?> getGroupSafety(
    int year,
    String make,
    String model,
  ) async {
    calls++;
    if (failure != null) throw failure!;
    return result;
  }
}

class _FakeRecalls implements RecallsRepository {
  RecallSummaryEntity? result = const RecallSummaryEntity(
    recalls: [RecallEntity(campaignNumber: '24V128000')],
  );
  AppFailure? failure;
  int calls = 0;

  @override
  Future<RecallSummaryEntity?> getRecalls(
    int year,
    String make,
    String model,
  ) async {
    calls++;
    if (failure != null) throw failure!;
    return result;
  }
}

void main() {
  late _MemoryCache cache;
  late _FakeRatings ratings;
  late _FakeRecalls recalls;
  late DateTime now;
  late ResolveGroupSafetyUseCase useCase;

  setUp(() {
    cache = _MemoryCache();
    ratings = _FakeRatings();
    recalls = _FakeRecalls();
    now = DateTime(2026, 6, 1);
    useCase = ResolveGroupSafetyUseCase(
      cache: cache,
      ratingsRepository: ratings,
      recallsRepository: recalls,
      keyBuilder: const SafetyKeyBuilder(),
      clock: () => now,
    );
  });

  Future<GroupSafetyReportEntity> resolve() =>
      useCase(year: 2024, make: 'Toyota', model: 'Camry');

  test('miss: va a la red y guarda ambas cachés', () async {
    final report = await resolve();
    expect(report.safety!.maxOverall, 5);
    expect(report.recalls!.count, 1);
    expect(cache.ratings, hasLength(1));
    expect(cache.recalls, hasLength(1));
  });

  test('hit: la segunda llamada no usa la red', () async {
    await resolve();
    final report = await resolve();
    expect(ratings.calls, 1);
    expect(recalls.calls, 1);
    expect(report.safety!.ratedCount, 1);
    expect(report.recalls!.count, 1);
  });

  test('las estrellas vencen a los 30 días y los recalls a los 7', () async {
    await resolve();
    now = now.add(const Duration(days: 8));
    await resolve();
    expect(ratings.calls, 1);
    expect(recalls.calls, 2);
    now = now.add(const Duration(days: 23));
    await resolve();
    expect(ratings.calls, 2);
  });

  test('vencido con la red caída devuelve la entrada vencida', () async {
    await resolve();
    now = now.add(const Duration(days: 40));
    ratings.failure = const NetworkFailure('sin red');
    recalls.failure = const NetworkFailure('sin red');
    final report = await resolve();
    expect(report.safety!.maxOverall, 5);
    expect(report.recalls!.count, 1);
  });

  test('sin caché y con la red caída relanza la falla', () async {
    ratings.failure = const NetworkFailure('sin red');
    expect(resolve(), throwsA(isA<NetworkFailure>()));
  });

  test(
    'sin emparejar: estrellas nulas, se marca y no se repite 3 días',
    () async {
      ratings.result = null;
      recalls.result = null;
      final first = await resolve();
      expect(first.safety, isNull);
      expect(first.recalls, isNull);
      expect(cache.noMatch, hasLength(2));
      now = now.add(const Duration(days: 2));
      await resolve();
      expect(ratings.calls, 1);
      expect(recalls.calls, 1);
      now = now.add(const Duration(days: 2));
      await resolve();
      expect(ratings.calls, 2);
    },
  );

  test('sin emparejar pero con recalls, los recalls se conservan', () async {
    ratings.result = null;
    final report = await resolve();
    expect(report.safety, isNull);
    expect(report.recalls!.count, 1);
  });

  test(
    'marca de no emparejado vencida y red caída sigue siendo nulo',
    () async {
      ratings.result = null;
      await resolve();
      now = now.add(const Duration(days: 10));
      ratings.failure = const NetworkFailure('sin red');
      recalls.failure = const NetworkFailure('sin red');
      final report = await resolve();
      expect(report.safety, isNull);
    },
  );

  test('una falla se distingue de "0 recalls" confirmado', () async {
    recalls.result = const RecallSummaryEntity(recalls: []);
    final report = await resolve();
    expect(report.recalls!.count, 0);
  });
}
