import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryCache implements SummaryCacheDatasource {
  final Map<String, CachedSummaryEntity> entries = {};
  final List<int> writes = [0];

  @override
  Future<CachedSummaryEntity?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, CachedSummaryEntity entry) async {
    writes[0]++;
    entries[key] = entry;
  }
}

class _FakeRepository implements VehicleSpecsRepository {
  GroupSummaryEntity? summary;
  AppFailure? error;
  final List<List<String>> requestedNames = [];
  final List<int> cancels = [0];

  @override
  Future<void> cancelPendingRequests() async => cancels[0]++;

  @override
  Future<GroupSummaryEntity?> getSummary(
    int year,
    String brand,
    List<String> variantNames,
  ) async {
    requestedNames.add(variantNames);
    final failure = error;
    if (failure != null) throw failure;
    return summary;
  }
}

const GroupSummaryEntity _fresh = GroupSummaryEntity(
  vehicleClass: 'Compact Cars',
  minKmPerLiter: 12.5,
  maxKmPerLiter: 14.5,
  hasElectric: false,
  hasPluginHybrid: false,
  variantCount: 2,
);
const GroupSummaryEntity _old = GroupSummaryEntity(
  vehicleClass: 'Midsize Cars',
  minKmPerLiter: null,
  maxKmPerLiter: null,
  hasElectric: true,
  hasPluginHybrid: false,
  variantCount: 1,
);
const String _key =
    '${VehicleSpecsConfig.summaryCacheKeyVersion}|honda|civic|2020';
const List<String> _variants = ['Civic Si', 'Civic'];

void main() {
  final now = DateTime(2026, 6, 1);
  const lifetime = Duration(
    days: VehicleSpecsConfig.summaryCacheTimeToLiveDays,
  );
  late _MemoryCache cache;
  late _FakeRepository repository;
  late ResolveGroupSummaryUseCase resolve;

  setUp(() {
    cache = _MemoryCache();
    repository = _FakeRepository()..summary = _fresh;
    resolve = ResolveGroupSummaryUseCase(
      cache: cache,
      getGroupSummary: GetGroupSummaryUseCase(repository),
      keyBuilder: const SummaryKeyBuilder(),
      clock: () => now,
    );
  });

  Future<GroupSummaryEntity?> run() => resolve(
    year: 2020,
    brand: 'Honda',
    groupName: 'Civic',
    variantNames: _variants,
  );

  test('GetGroupSummaryUseCase pide todas las variantes del grupo', () async {
    await run();
    expect(repository.requestedNames, [_variants]);
  });

  test('la clave de caché lleva la versión', () async {
    await run();
    expect(cache.entries.keys.single, startsWith('v3|'));
    expect(VehicleSpecsConfig.summaryCacheKeyVersion, 'v3');
  });

  test('una entrada con otra versión de clave se ignora', () async {
    cache.entries['honda|civic|2020'] = CachedSummaryEntity(
      summary: _old,
      savedAt: now,
    );
    expect(await run(), _fresh);
  });

  test('CancelPendingSummariesUseCase cancela en el repositorio', () async {
    await CancelPendingSummariesUseCase(repository)();
    expect(repository.cancels[0], 1);
  });

  test('una entrada vigente se devuelve sin red', () async {
    cache.entries[_key] = CachedSummaryEntity(
      summary: _old,
      savedAt: now.subtract(const Duration(days: 1)),
    );
    expect(await run(), _old);
    expect(repository.requestedNames, isEmpty);
  });

  test('sin entrada va a la red y guarda el resumen', () async {
    expect(await run(), _fresh);
    expect(cache.entries[_key]?.summary, _fresh);
    expect(cache.entries[_key]?.savedAt, now);
  });

  test('una entrada vencida va a la red y se reemplaza', () async {
    cache.entries[_key] = CachedSummaryEntity(
      summary: _old,
      savedAt: now.subtract(const Duration(days: 40)),
    );
    expect(await run(), _fresh);
    expect(cache.entries[_key]?.summary, _fresh);
  });

  test('vencida y sin red devuelve la vencida sin guardar', () async {
    cache.entries[_key] = CachedSummaryEntity(
      summary: _old,
      savedAt: now.subtract(const Duration(days: 40)),
    );
    repository.error = const NetworkFailure('sin red');
    expect(await run(), _old);
    expect(cache.writes[0], 0);
  });

  test('sin entrada y con fallo relanza', () async {
    repository.error = const NetworkFailure('sin red');
    await expectLater(run(), throwsA(isA<NetworkFailure>()));
    expect(cache.writes[0], 0);
  });

  test('un resultado nulo no se guarda', () async {
    repository.summary = null;
    expect(await run(), isNull);
    expect(cache.writes[0], 0);
  });

  test('justo en el límite de vigencia ya se considera vencida', () async {
    cache.entries[_key] = CachedSummaryEntity(
      summary: _old,
      savedAt: now.subtract(lifetime),
    );
    expect(await run(), _fresh);
  });

  test('un segundo antes del límite sigue vigente', () async {
    cache.entries[_key] = CachedSummaryEntity(
      summary: _old,
      savedAt: now.subtract(lifetime - const Duration(seconds: 1)),
    );
    expect(await run(), _old);
    expect(repository.requestedNames, isEmpty);
  });
}
