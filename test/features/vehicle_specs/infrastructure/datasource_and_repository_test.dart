import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _FakeDatasource implements VehicleSpecsDatasource {
  /// Ids por nombre de variante; sin entrada = sin opciones.
  final Map<String, List<int>> idsByVariant = {};

  /// Registro por id.
  final Map<int, VehicleRecordEntity?> recordsById = {};

  /// Fallos por nombre de variante.
  final Map<String, AppFailure> failuresByVariant = {};

  /// Si no es nulo, fetchOptionIds espera a este completer.
  Completer<void>? gate;
  final List<String> startedVariants = [];
  final List<int> fetchedIds = [];

  @override
  Future<List<int>> fetchOptionIds(int year, String brand, String model) async {
    startedVariants.add(model);
    await gate?.future;
    final failure = failuresByVariant[model];
    if (failure != null) throw failure;
    return idsByVariant[model] ?? [];
  }

  @override
  Future<List<VehicleOptionEntity>> fetchOptions(
    int year,
    String brand,
    String model,
  ) async {
    final ids = await fetchOptionIds(year, brand, model);
    return [for (final id in ids) VehicleOptionEntity(id: id, text: '')];
  }

  @override
  Future<VehicleRecordEntity?> fetchVehicle(int id) async {
    fetchedIds.add(id);
    return recordsById[id];
  }
}

VehicleRecordEntity _record(double mpg, {String atvType = ''}) =>
    VehicleRecordEntity(
      vehicleClass: 'Compact Cars',
      atvType: atvType,
      combinedMpg: mpg,
    );

Response<Object?> _response(Object? data) => Response<Object?>(
  data: data,
  requestOptions: RequestOptions(path: '/x'),
);

void main() {
  group('FuelEconomyVehicleSpecsDatasource', () {
    late _MockDio dio;
    late ConcurrencyLimitedQueue queue;
    late FuelEconomyVehicleSpecsDatasource datasource;

    setUp(() {
      dio = _MockDio();
      queue = ConcurrencyLimitedQueue(maxConcurrent: 2);
      datasource = FuelEconomyVehicleSpecsDatasource(dio: dio, queue: queue);
    });

    test('fetchOptionIds usa la ruta y los parámetros configurados', () async {
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _response({
          'menuItem': [
            {'text': 'Auto', 'value': '41213'},
          ],
        }),
      );
      expect(await datasource.fetchOptionIds(2020, 'Honda', 'Civic'), [41213]);
      verify(
        () => dio.get<Object?>(
          VehicleSpecsConfig.optionsPath,
          queryParameters: {
            FuelEconomyConfig.yearQueryParameter: 2020,
            FuelEconomyConfig.makeQueryParameter: 'Honda',
            VehicleSpecsConfig.modelQueryParameter: 'Civic',
          },
        ),
      ).called(1);
    });

    test('fetchVehicle pide la ruta con el id y mapea el registro', () async {
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _response({
          'VClass': 'Compact Cars',
          'atvType': '',
          'comb08': '34',
        }),
      );
      final record = await datasource.fetchVehicle(41213);
      expect(
        record,
        const VehicleRecordEntity(
          vehicleClass: 'Compact Cars',
          atvType: '',
          combinedMpg: 34,
        ),
      );
      verify(() => dio.get<Object?>('/41213', queryParameters: null)).called(1);
    });

    test('una respuesta sin cuerpo da registro nulo', () async {
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _response(null));
      expect(await datasource.fetchVehicle(1), isNull);
    });

    test('los errores de Dio se traducen a AppFailure', () async {
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      await expectLater(
        datasource.fetchVehicle(1),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('cada petición entra a la cola', () async {
      // Con la cola cerrada la petición se rechaza antes de llegar a Dio.
      await queue.close();
      await expectLater(
        datasource.fetchOptionIds(2020, 'Honda', 'Civic'),
        throwsA(isA<StateError>()),
      );
      verifyNever(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      );
    });
  });

  group('VehicleSpecsRepositoryImpl', () {
    late _FakeDatasource datasource;
    late ConcurrencyLimitedQueue queue;
    late VehicleSpecsRepositoryImpl repository;

    setUp(() {
      datasource = _FakeDatasource();
      queue = ConcurrencyLimitedQueue(maxConcurrent: 1);
      repository = VehicleSpecsRepositoryImpl(
        datasource: datasource,
        queue: queue,
      );
    });

    test('todas las variantes aportan al resumen', () async {
      datasource
        ..idsByVariant['A'] = [1]
        ..idsByVariant['B'] = [2]
        ..recordsById[1] = _record(20)
        ..recordsById[2] = _record(40);
      final summary = await repository.getSummary(2020, 'Honda', ['A', 'B']);
      expect(summary?.variantCount, 2);
      expect(
        summary?.minKmPerLiter,
        closeTo(20 * UnitsConfig.milesPerGallonToKilometersPerLiter, 1e-9),
      );
      expect(
        summary?.maxKmPerLiter,
        closeTo(40 * UnitsConfig.milesPerGallonToKilometersPerLiter, 1e-9),
      );
    });

    test('una variante sin opciones se omite', () async {
      datasource
        ..idsByVariant['A'] = [1]
        ..recordsById[1] = _record(30);
      final summary = await repository.getSummary(2020, 'Honda', ['A', 'B']);
      expect(summary?.variantCount, 1);
    });

    test('una falla de servidor se omite y las demás cuentan', () async {
      datasource
        ..failuresByVariant['A'] = const ServerFailure('500')
        ..idsByVariant['B'] = [2]
        ..recordsById[2] = _record(30);
      final summary = await repository.getSummary(2020, 'Honda', ['A', 'B']);
      expect(summary?.variantCount, 1);
    });

    test('un fallo de red con otra variante leída no relanza', () async {
      datasource
        ..failuresByVariant['A'] = const NetworkFailure('sin red')
        ..idsByVariant['B'] = [2]
        ..recordsById[2] = _record(30);
      final summary = await repository.getSummary(2020, 'Honda', ['A', 'B']);
      expect(summary?.variantCount, 1);
    });

    test('si todas fallan por red relanza NetworkFailure', () async {
      datasource
        ..failuresByVariant['A'] = const NetworkFailure('sin red')
        ..failuresByVariant['B'] = const NetworkFailure('sin red');
      await expectLater(
        repository.getSummary(2020, 'Honda', ['A', 'B']),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('red caída en una y servidor en otra relanza la de red', () async {
      datasource
        ..failuresByVariant['A'] = const ServerFailure('500')
        ..failuresByVariant['B'] = const NetworkFailure('sin red');
      await expectLater(
        repository.getSummary(2020, 'Honda', ['A', 'B']),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('si solo hay fallas de servidor devuelve nulo', () async {
      datasource.failuresByVariant['A'] = const ServerFailure('500');
      expect(await repository.getSummary(2020, 'Honda', ['A']), isNull);
    });

    test('sin opciones en ninguna variante devuelve nulo', () async {
      expect(await repository.getSummary(2020, 'Honda', ['A', 'B']), isNull);
      expect(datasource.fetchedIds, isEmpty);
    });

    test('un registro nulo cuenta como variante omitida', () async {
      datasource.idsByVariant['A'] = [1];
      expect(await repository.getSummary(2020, 'Honda', ['A']), isNull);
    });

    test('toma la primera opción de cada variante', () async {
      datasource
        ..idsByVariant['A'] = [10, 11]
        ..idsByVariant['B'] = [20, 21]
        ..recordsById[10] = _record(30)
        ..recordsById[20] = _record(30);
      await repository.getSummary(2020, 'Honda', ['A', 'B']);
      expect(datasource.fetchedIds, unorderedEquals([10, 20]));
    });

    test('una cancelación se relanza de inmediato', () async {
      datasource
        ..failuresByVariant['A'] = const CancelledFailure('cancelada')
        ..idsByVariant['B'] = [2]
        ..recordsById[2] = _record(30);
      await expectLater(
        repository.getSummary(2020, 'Honda', ['A', 'B']),
        throwsA(isA<CancelledFailure>()),
      );
    });

    test('lanza todas las consultas antes de que la primera termine', () async {
      final gate = Completer<void>();
      datasource
        ..gate = gate
        ..idsByVariant['A'] = [1]
        ..recordsById[1] = _record(30);
      final future = repository.getSummary(2020, 'Honda', ['A', 'B', 'C']);
      await Future<void>.delayed(Duration.zero);
      expect(datasource.startedVariants, ['A', 'B', 'C']);
      gate.complete();
      expect((await future)?.variantCount, 1);
    });

    test('cancelPendingRequests cancela lo pendiente en la cola', () async {
      final blocker = queue.enqueue(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return 1;
      });
      final pending = queue.enqueue(() async => 2);
      final expectation = expectLater(
        pending,
        throwsA(isA<CancelledFailure>()),
      );
      await repository.cancelPendingRequests();
      await expectation;
      expect(await blocker, 1);
    });
  });
}
