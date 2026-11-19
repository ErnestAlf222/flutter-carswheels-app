import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/conuee_test_support.dart';

class _FakeDatasource implements MexicoCatalogDatasource {
  int sourceCalls = 0;
  int yearCalls = 0;
  AppFailure? failure;
  List<MxYearSourceEntity> sources = const [
    MxYearSourceEntity(year: 2026, resourceId: 'r26'),
    MxYearSourceEntity(year: 2025, resourceId: 'r25'),
  ];

  @override
  Future<List<MxYearSourceEntity>> fetchYearSources() async {
    sourceCalls++;
    if (failure != null) throw failure!;
    return sources;
  }

  @override
  Future<MxYearCatalogEntity> fetchYear(MxYearSourceEntity source) async {
    yearCalls++;
    if (failure != null) throw failure!;
    await Future<void>.delayed(Duration.zero);
    return mxCatalog(source.year, [mxVehicle('Audi', 'A3')]);
  }
}

class _FakeCache implements MexicoCatalogCacheDatasource {
  final Map<String, CachedMxYearsEntity> years = {};
  final Map<String, CachedMxYearEntity> catalogs = {};

  @override
  Future<CachedMxYearsEntity?> readYears(String key) async => years[key];

  @override
  Future<void> writeYears(String key, CachedMxYearsEntity entry) async =>
      years[key] = entry;

  @override
  Future<CachedMxYearEntity?> readYear(String key) async => catalogs[key];

  @override
  Future<void> writeYear(String key, CachedMxYearEntity entry) async =>
      catalogs[key] = entry;
}

void main() {
  late _FakeDatasource datasource;
  late _FakeCache cache;
  late DateTime now;

  MexicoCatalogRepositoryImpl build() => MexicoCatalogRepositoryImpl(
    datasource: datasource,
    cache: cache,
    clock: () => now,
  );

  const ttl = Duration(days: ConueeConfig.cacheTimeToLiveDays);

  setUp(() {
    datasource = _FakeDatasource();
    cache = _FakeCache();
    now = DateTime(2026, 11, 18);
  });

  test(
    'sin caché va a la red una vez y guarda con claves versionadas',
    () async {
      final repository = build();
      expect(await repository.fetchYears(), [2026, 2025]);
      final catalog = await repository.fetchYear(2025);
      expect(catalog.year, 2025);
      expect(datasource.sourceCalls, 1);
      expect(datasource.yearCalls, 1);
      expect(cache.years.keys.single, startsWith(ConueeConfig.cacheKeyVersion));
      expect(cache.catalogs.keys.single, 'v2|year|2025');
    },
  );

  test('la segunda lectura sale de memoria: 0 peticiones', () async {
    final repository = build();
    await repository.fetchYear(2025);
    await repository.fetchYear(2025);
    await repository.fetchYears();
    expect(datasource.yearCalls, 1);
    expect(datasource.sourceCalls, 1);
  });

  test('peticiones simultáneas del mismo año comparten una sola', () async {
    final repository = build();
    await Future.wait([repository.fetchYear(2025), repository.fetchYear(2025)]);
    expect(datasource.yearCalls, 1);
  });

  test('entrada vigente en disco: no toca la red', () async {
    await build().fetchYear(2025);
    final calls = datasource.yearCalls;
    now = now.add(ttl - const Duration(minutes: 1));
    final fresh = build();
    expect((await fresh.fetchYear(2025)).year, 2025);
    expect(await fresh.fetchYears(), [2026, 2025]);
    expect(datasource.yearCalls, calls);
    expect(datasource.sourceCalls, 1);
  });

  test('entrada vencida: vuelve a la red y actualiza la fecha', () async {
    await build().fetchYear(2025);
    now = now.add(ttl + const Duration(minutes: 1));
    await build().fetchYear(2025);
    expect(datasource.yearCalls, 2);
    expect(datasource.sourceCalls, 2);
    expect(cache.catalogs['v2|year|2025']!.savedAt, now);
  });

  test('red caída con entrada vencida: devuelve la vencida', () async {
    await build().fetchYear(2025);
    now = now.add(ttl + const Duration(days: 30));
    datasource.failure = const NetworkFailure('sin red');
    final repository = build();
    expect((await repository.fetchYear(2025)).year, 2025);
    expect(await repository.fetchYears(), [2026, 2025]);
  });

  test('red caída sin caché: relanza el error', () async {
    datasource.failure = const NetworkFailure('sin red');
    expect(build().fetchYear(2025), throwsA(isA<NetworkFailure>()));
    expect(build().fetchYears(), throwsA(isA<NetworkFailure>()));
  });

  test('un año que no se ofrece es ParsingFailure', () async {
    expect(build().fetchYear(1999), throwsA(isA<ParsingFailure>()));
  });

  test(
    'un error no se queda atascado: el siguiente intento reintenta',
    () async {
      datasource.failure = const ServerFailure('500');
      final repository = build();
      await expectLater(
        repository.fetchYear(2025),
        throwsA(isA<ServerFailure>()),
      );
      datasource.failure = null;
      expect((await repository.fetchYear(2025)).year, 2025);
    },
  );
}
