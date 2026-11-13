import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _FakeDatasource implements VehicleSpecsDatasource {
  List<int> ids = [];
  VehicleRecordEntity? record;
  final List<int> fetchedIds = [];

  @override
  Future<List<int>> fetchOptionIds(
    int year,
    String brand,
    String model,
  ) async => ids;

  @override
  Future<VehicleRecordEntity?> fetchVehicle(int id) async {
    fetchedIds.add(id);
    return record;
  }
}

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

    test('sin opciones devuelve nulo y no pide registro', () async {
      expect(await repository.getSummary(2020, 'Honda', 'Civic'), isNull);
      expect(datasource.fetchedIds, isEmpty);
    });

    test('toma la primera opción en el orden de la API', () async {
      datasource
        ..ids = [41213, 41214]
        ..record = const VehicleRecordEntity(
          vehicleClass: 'Compact Cars',
          atvType: '',
          combinedMpg: 34,
        );
      final summary = await repository.getSummary(2020, 'Honda', 'Civic');
      expect(datasource.fetchedIds, [41213]);
      expect(summary?.powertrain, Powertrain.combustion);
      expect(summary?.vehicleClass, 'Compact Cars');
    });

    test('un registro nulo devuelve nulo', () async {
      datasource.ids = [1];
      expect(await repository.getSummary(2020, 'Honda', 'Civic'), isNull);
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
