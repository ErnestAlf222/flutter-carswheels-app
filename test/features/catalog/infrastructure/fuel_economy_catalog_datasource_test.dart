import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

Response<Object?> _response(Object? data) => Response<Object?>(
  data: data,
  requestOptions: RequestOptions(path: '/x'),
);

DioException _error(DioExceptionType type) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  type: type,
);

void main() {
  late _MockDio dio;
  late FuelEconomyCatalogDatasource datasource;

  setUp(() {
    dio = _MockDio();
    datasource = FuelEconomyCatalogDatasource(dio);
  });

  void stubGet(Object? data) {
    when(
      () => dio.get<Object?>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => _response(data));
  }

  void stubGetError(DioExceptionType type) {
    when(
      () => dio.get<Object?>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(_error(type));
  }

  test('fetchYears devuelve los años y usa la ruta configurada', () async {
    stubGet({
      'menuItem': [
        {'text': '2027', 'value': '2027'},
        {'text': '2026', 'value': '2026'},
      ],
    });
    expect(await datasource.fetchYears(), [2027, 2026]);
    verify(
      () => dio.get<Object?>(
        FuelEconomyConfig.menuYearPath,
        queryParameters: null,
      ),
    ).called(1);
  });

  test('fetchBrands devuelve las marcas y envía el año', () async {
    stubGet({
      'menuItem': [
        {'text': 'Acura', 'value': 'Acura'},
        {'text': 'Audi', 'value': 'Audi'},
      ],
    });
    expect(await datasource.fetchBrands(2020), const [
      BrandEntity(name: 'Acura'),
      BrandEntity(name: 'Audi'),
    ]);
    verify(
      () => dio.get<Object?>(
        FuelEconomyConfig.menuMakePath,
        queryParameters: {FuelEconomyConfig.yearQueryParameter: 2020},
      ),
    ).called(1);
  });

  test('una respuesta inválida lanza ParsingFailure', () async {
    stubGet('no es json');
    await expectLater(datasource.fetchYears(), throwsA(isA<ParsingFailure>()));
  });

  const networkTypes = [
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  ];
  for (final type in networkTypes) {
    test('$type produce NetworkFailure', () async {
      stubGetError(type);
      await expectLater(
        datasource.fetchYears(),
        throwsA(isA<NetworkFailure>()),
      );
    });
  }

  test('badResponse produce ServerFailure', () async {
    stubGetError(DioExceptionType.badResponse);
    await expectLater(
      datasource.fetchBrands(2020),
      throwsA(isA<ServerFailure>()),
    );
  });

  test('otros tipos producen UnknownFailure', () async {
    stubGetError(DioExceptionType.cancel);
    await expectLater(datasource.fetchYears(), throwsA(isA<UnknownFailure>()));
  });
}
