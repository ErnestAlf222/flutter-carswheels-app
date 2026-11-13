import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGetGroupOptions implements GetGroupOptionsUseCase {
  _FakeGetGroupOptions(this.options);

  final List<GroupOptionEntity> options;

  @override
  VehicleSpecsRepository get repository => throw UnimplementedError();

  @override
  Future<List<GroupOptionEntity>> call({
    required int year,
    required String brand,
    required List<String> variantNames,
  }) async => options;
}

class _FakeResolve implements ResolveVehicleDetailUseCase {
  _FakeResolve(this.answer);

  final Future<VehicleDetailEntity?> Function(int id, String model) answer;
  final List<int> requestedIds = [];
  final List<String> requestedModels = [];

  @override
  VehicleDetailCacheDatasource get cache => throw UnimplementedError();
  @override
  VehicleSpecsRepository get repository => throw UnimplementedError();
  @override
  VehicleDetailKeyBuilder get keyBuilder => throw UnimplementedError();
  @override
  DateTime Function() get clock => throw UnimplementedError();

  @override
  Future<VehicleDetailEntity?> call({
    required int id,
    required int year,
    required String brand,
    required String model,
  }) {
    requestedIds.add(id);
    requestedModels.add(model);
    return answer(id, model);
  }
}

VehicleDetailEntity _detail(int id, double? combined, {String model = 'M'}) =>
    VehicleDetailEntity(
      id: id,
      year: 2020,
      make: 'Toyota',
      model: model,
      vehicleClass: null,
      powertrain: Powertrain.combustion,
      transmission: null,
      cylinders: null,
      displacementLiters: null,
      drive: null,
      fuelType: null,
      cityKmPerLiter: null,
      highwayKmPerLiter: null,
      combinedKmPerLiter: combined,
      annualFuelCostUsd: null,
    );

GroupOptionEntity _option(String variant, int id) => GroupOptionEntity(
  variantName: variant,
  option: VehicleOptionEntity(id: id, text: 'op $id'),
);

const DetailArgsEntity _args = DetailArgsEntity(
  brand: 'Toyota',
  groupName: 'Camry',
  year: 2020,
  variantNames: ['Camry', 'Camry Hybrid'],
  photo: null,
  heroTag: 'tag',
);

LoadGroupDetailsUseCase _useCase(
  List<GroupOptionEntity> options,
  _FakeResolve resolve,
) => LoadGroupDetailsUseCase(
  getGroupOptions: _FakeGetGroupOptions(options),
  resolveVehicleDetail: resolve,
  defaultVersionSelector: const DefaultVersionSelector(),
);

void main() {
  final options = [
    _option('Camry', 1),
    _option('Camry', 2),
    _option('Camry Hybrid', 3),
  ];

  test(
    'conserva el orden por variante y por opción y pide con la variante',
    () async {
      final resolve = _FakeResolve(
        (id, model) async => _detail(id, 10.0 + id, model: model),
      );
      final result = await _useCase(options, resolve)(_args);
      expect(result.versions.map((v) => v.detail.id), [1, 2, 3]);
      expect(result.versions.map((v) => v.variantName), [
        'Camry',
        'Camry',
        'Camry Hybrid',
      ]);
      expect(resolve.requestedModels, ['Camry', 'Camry', 'Camry Hybrid']);
    },
  );

  test('el defaultIndex apunta al detalle mediano', () async {
    final consumption = {1: 9.0, 2: 14.0, 3: 11.0};
    final resolve = _FakeResolve((id, _) async => _detail(id, consumption[id]));
    final result = await _useCase(options, resolve)(_args);
    expect(result.defaultIndex, 2);
    expect(result.versions[result.defaultIndex].detail.id, 3);
  });

  test(
    'una opción sin detalle se omite y el índice cuenta las que quedan',
    () async {
      final resolve = _FakeResolve(
        (id, _) async => id == 1 ? null : _detail(id, id == 2 ? 8 : 12),
      );
      final result = await _useCase(options, resolve)(_args);
      expect(result.versions.map((v) => v.detail.id), [2, 3]);
      expect(result.defaultIndex, 0);
    },
  );

  test('una falla de servidor se omite', () async {
    final resolve = _FakeResolve((id, _) async {
      if (id == 2) throw const ServerFailure('500');
      return _detail(id, 10);
    });
    final result = await _useCase(options, resolve)(_args);
    expect(result.versions.map((v) => v.detail.id), [1, 3]);
  });

  test('si todas fallan por red relanza el NetworkFailure', () async {
    final resolve = _FakeResolve((id, _) async {
      throw const NetworkFailure('sin red');
    });
    await expectLater(
      _useCase(options, resolve)(_args),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('si quedan sin versiones pero hubo red caída y otra falla, relanza la de red', () async {
    final resolve = _FakeResolve((id, _) async {
      if (id == 1) throw const ServerFailure('500');
      throw const NetworkFailure('sin red');
    });
    await expectLater(
      _useCase(options, resolve)(_args),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('sin versiones y sin fallos de red: lista vacía e índice 0', () async {
    final noDetail = _FakeResolve((id, _) async => null);
    final empty = await _useCase(options, noDetail)(_args);
    expect(empty.versions, isEmpty);
    expect(empty.defaultIndex, 0);

    final serverOnly = _FakeResolve((id, _) async {
      throw const ServerFailure('500');
    });
    final failed = await _useCase(options, serverOnly)(_args);
    expect(failed.versions, isEmpty);

    final noOptions = await _useCase([], _FakeResolve((_, _) async => null))(
      _args,
    );
    expect(noOptions.versions, isEmpty);
  });

  test('CancelledFailure se relanza', () async {
    final resolve = _FakeResolve((id, _) async {
      if (id == 2) throw const CancelledFailure('cancelado');
      return _detail(id, 10);
    });
    await expectLater(
      _useCase(options, resolve)(_args),
      throwsA(isA<CancelledFailure>()),
    );
  });

  test(
    'pide el detalle de todas las opciones antes de que termine la primera',
    () async {
      final completers = {
        for (final o in options) o.option.id: Completer<VehicleDetailEntity?>(),
      };
      final resolve = _FakeResolve((id, _) => completers[id]!.future);
      final future = _useCase(options, resolve)(_args);
      await Future<void>.delayed(Duration.zero);
      // Ninguna terminó y ya se pidieron las tres.
      expect(resolve.requestedIds, [1, 2, 3]);
      for (final entry in completers.entries) {
        entry.value.complete(_detail(entry.key, 10));
      }
      final result = await future;
      expect(result.versions, hasLength(3));
    },
  );
}
