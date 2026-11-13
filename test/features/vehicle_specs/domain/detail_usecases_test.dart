import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements VehicleSpecsRepository {
  /// Opciones por nombre de variante; sin entrada = sin opciones.
  final Map<String, List<VehicleOptionEntity>> optionsByVariant = {};
  final Map<String, AppFailure> failuresByVariant = {};
  VehicleDetailEntity? detail;
  AppFailure? detailFailure;
  final List<String> requestedVariants = [];
  final List<int> detailRequests = [];

  @override
  Future<List<VehicleOptionEntity>> getOptions(
    int year,
    String brand,
    String model,
  ) async {
    requestedVariants.add(model);
    final failure = failuresByVariant[model];
    if (failure != null) throw failure;
    return optionsByVariant[model] ?? [];
  }

  @override
  Future<VehicleDetailEntity?> getDetail(
    int id, {
    required int year,
    required String brand,
    required String model,
  }) async {
    detailRequests.add(id);
    final failure = detailFailure;
    if (failure != null) throw failure;
    return detail;
  }

  @override
  Future<GroupSummaryEntity?> getSummary(
    int year,
    String brand,
    List<String> variantNames,
  ) => throw UnimplementedError();

  @override
  Future<void> cancelPendingRequests() async {}
}

class _MemoryDetailCache implements VehicleDetailCacheDatasource {
  final Map<String, CachedDetailEntity> entries = {};
  int writes = 0;

  @override
  Future<CachedDetailEntity?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, CachedDetailEntity entry) async {
    writes++;
    entries[key] = entry;
  }
}

VehicleOptionEntity _option(int id) =>
    VehicleOptionEntity(id: id, text: 'opción $id');

VehicleDetailEntity _detail(int id, {String model = 'Corolla'}) =>
    VehicleDetailEntity(
      id: id,
      year: 2020,
      make: 'Toyota',
      model: model,
      vehicleClass: 'Compact Cars',
      powertrain: Powertrain.combustion,
      transmission: 'Automatic (AV-S10)',
      cylinders: 4,
      displacementLiters: 2.0,
      drive: 'Front-Wheel Drive',
      fuelType: 'Regular',
      cityKmPerLiter: 13.1,
      highwayKmPerLiter: 17,
      combinedKmPerLiter: 14.5,
      annualFuelCostUsd: 1750,
    );

void main() {
  group('GetGroupOptionsUseCase', () {
    late _FakeRepository repository;
    late GetGroupOptionsUseCase useCase;

    setUp(() {
      repository = _FakeRepository();
      useCase = GetGroupOptionsUseCase(repository);
    });

    Future<List<GroupOptionEntity>> call(List<String> variants) =>
        useCase(year: 2020, brand: 'Toyota', variantNames: variants);

    test('respeta el orden de las variantes y el de la API', () async {
      repository
        ..optionsByVariant['B'] = [_option(5), _option(2)]
        ..optionsByVariant['A'] = [_option(9), _option(1)];
      final options = await call(['B', 'A']);
      expect(options, [
        GroupOptionEntity(variantName: 'B', option: _option(5)),
        GroupOptionEntity(variantName: 'B', option: _option(2)),
        GroupOptionEntity(variantName: 'A', option: _option(9)),
        GroupOptionEntity(variantName: 'A', option: _option(1)),
      ]);
    });

    test('pide las opciones de cada variante', () async {
      await call(['A', 'B', 'C']);
      expect(repository.requestedVariants, ['A', 'B', 'C']);
    });

    test('una variante que falla se omite', () async {
      repository
        ..failuresByVariant['A'] = const ServerFailure('500')
        ..optionsByVariant['B'] = [_option(2)];
      expect(await call(['A', 'B']), [
        GroupOptionEntity(variantName: 'B', option: _option(2)),
      ]);
    });

    test('una falla de red con otra variante leída no relanza', () async {
      repository
        ..failuresByVariant['A'] = const NetworkFailure('sin red')
        ..optionsByVariant['B'] = [_option(2)];
      expect(await call(['A', 'B']), hasLength(1));
    });

    test('si todas fallan por red relanza NetworkFailure', () async {
      repository
        ..failuresByVariant['A'] = const NetworkFailure('sin red')
        ..failuresByVariant['B'] = const NetworkFailure('sin red');
      await expectLater(call(['A', 'B']), throwsA(isA<NetworkFailure>()));
    });

    test('si todas fallan pero no todas por red devuelve vacío', () async {
      repository
        ..failuresByVariant['A'] = const ServerFailure('500')
        ..failuresByVariant['B'] = const NetworkFailure('sin red');
      expect(await call(['A', 'B']), isEmpty);
    });

    test('CancelledFailure se relanza', () async {
      repository
        ..failuresByVariant['A'] = const CancelledFailure('cancelada')
        ..optionsByVariant['B'] = [_option(2)];
      await expectLater(call(['A', 'B']), throwsA(isA<CancelledFailure>()));
    });

    test('variantes sin opciones dan lista vacía sin error', () async {
      expect(await call(['A', 'B']), isEmpty);
    });

    test('sin variantes da lista vacía', () async {
      expect(await call([]), isEmpty);
    });
  });

  group('ResolveVehicleDetailUseCase', () {
    late _FakeRepository repository;
    late _MemoryDetailCache cache;
    late DateTime now;
    late ResolveVehicleDetailUseCase useCase;
    const keyBuilder = VehicleDetailKeyBuilder();
    final key = keyBuilder.build(41213);
    final start = DateTime(2026, 11, 13, 10);
    const lifetime = Duration(
      days: VehicleSpecsConfig.vehicleDetailCacheTimeToLiveDays,
    );

    setUp(() {
      repository = _FakeRepository();
      cache = _MemoryDetailCache();
      now = start;
      useCase = ResolveVehicleDetailUseCase(
        cache: cache,
        repository: repository,
        keyBuilder: keyBuilder,
        clock: () => now,
      );
    });

    Future<VehicleDetailEntity?> call() =>
        useCase(id: 41213, year: 2020, brand: 'Toyota', model: 'Corolla');

    test('una entrada vigente se devuelve sin red', () async {
      cache.entries[key] = CachedDetailEntity(
        detail: _detail(41213),
        savedAt: start,
      );
      expect(await call(), _detail(41213));
      expect(repository.detailRequests, isEmpty);
      expect(cache.writes, 0);
    });

    test('sin entrada va a la red y guarda con la hora del reloj', () async {
      repository.detail = _detail(41213);
      expect(await call(), _detail(41213));
      expect(repository.detailRequests, [41213]);
      expect(cache.entries[key]?.detail, _detail(41213));
      expect(cache.entries[key]?.savedAt, start);
    });

    test('una entrada vencida va a la red y se reemplaza', () async {
      cache.entries[key] = CachedDetailEntity(
        detail: _detail(41213, model: 'Vieja'),
        savedAt: start.subtract(lifetime + const Duration(days: 1)),
      );
      repository.detail = _detail(41213);
      expect(await call(), _detail(41213));
      expect(cache.entries[key]?.detail, _detail(41213));
      expect(cache.entries[key]?.savedAt, start);
    });

    test('vencida y sin red devuelve la vencida sin guardar', () async {
      final old = CachedDetailEntity(
        detail: _detail(41213, model: 'Vieja'),
        savedAt: start.subtract(lifetime + const Duration(days: 1)),
      );
      cache.entries[key] = old;
      repository.detailFailure = const NetworkFailure('sin red');
      expect(await call(), old.detail);
      expect(cache.writes, 0);
    });

    test('sin entrada y con fallo relanza', () async {
      repository.detailFailure = const NetworkFailure('sin red');
      await expectLater(call(), throwsA(isA<NetworkFailure>()));
      expect(cache.writes, 0);
    });

    test('un resultado nulo se devuelve sin guardar', () async {
      expect(await call(), isNull);
      expect(cache.writes, 0);
    });

    test('un nulo con entrada vencida no devuelve la vencida', () async {
      cache.entries[key] = CachedDetailEntity(
        detail: _detail(41213, model: 'Vieja'),
        savedAt: start.subtract(lifetime + const Duration(days: 1)),
      );
      expect(await call(), isNull);
      expect(cache.writes, 0);
    });

    test('un instante antes del límite sigue vigente', () async {
      cache.entries[key] = CachedDetailEntity(
        detail: _detail(41213),
        savedAt: start.subtract(lifetime - const Duration(milliseconds: 1)),
      );
      await call();
      expect(repository.detailRequests, isEmpty);
    });

    test('justo en el límite ya está vencida', () async {
      cache.entries[key] = CachedDetailEntity(
        detail: _detail(41213),
        savedAt: start.subtract(lifetime),
      );
      repository.detail = _detail(41213);
      await call();
      expect(repository.detailRequests, [41213]);
    });
  });
}
