import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

// Adaptador que guarda la URL solicitada y responde un menú vacío.
class _RecordingAdapter implements HttpClientAdapter {
  Uri? requestedUri;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestedUri = options.uri;
    return ResponseBody.fromString(
      '{"menuItem":[]}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

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

  test('fetchModels envía año y marca como parámetros de consulta', () async {
    stubGet({
      'menuItem': [
        {'text': 'DBX', 'value': 'DBX'},
        {'text': 'Vantage', 'value': 'Vantage'},
      ],
    });
    expect(await datasource.fetchModels(2027, 'Aston Martin'), const [
      ModelEntity(name: 'DBX'),
      ModelEntity(name: 'Vantage'),
    ]);
    verify(
      () => dio.get<Object?>(
        FuelEconomyConfig.menuModelPath,
        queryParameters: {
          FuelEconomyConfig.yearQueryParameter: 2027,
          FuelEconomyConfig.makeQueryParameter: 'Aston Martin',
        },
      ),
    ).called(1);
  });

  test('fetchModels acepta un solo objeto y descarta textos vacíos', () async {
    stubGet({
      'menuItem': {'text': 'Chiron', 'value': 'Chiron'},
    });
    expect(await datasource.fetchModels(2020, 'Bugatti'), const [
      ModelEntity(name: 'Chiron'),
    ]);
    stubGet({
      'menuItem': [
        {'text': '', 'value': ''},
      ],
    });
    expect(await datasource.fetchModels(2020, 'Bugatti'), isEmpty);
  });

  test('la marca con espacios llega codificada en la URL final', () async {
    final adapter = _RecordingAdapter();
    final realDio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
      ..httpClientAdapter = adapter;
    await FuelEconomyCatalogDatasource(realDio)
        .fetchModels(2027, 'Aston Martin');
    expect(adapter.requestedUri!.queryParameters, {
      FuelEconomyConfig.yearQueryParameter: '2027',
      FuelEconomyConfig.makeQueryParameter: 'Aston Martin',
    });
    expect(
      adapter.requestedUri!.path,
      endsWith(FuelEconomyConfig.menuModelPath),
    );
    expect(adapter.requestedUri!.query, isNot(contains(' ')));
  });

  test('fetchModels traduce los errores de Dio', () async {
    stubGetError(DioExceptionType.connectionTimeout);
    await expectLater(
      datasource.fetchModels(2020, 'Audi'),
      throwsA(isA<NetworkFailure>()),
    );
    stubGetError(DioExceptionType.badResponse);
    await expectLater(
      datasource.fetchModels(2020, 'Audi'),
      throwsA(isA<ServerFailure>()),
    );
    stubGetError(DioExceptionType.cancel);
    await expectLater(
      datasource.fetchModels(2020, 'Audi'),
      throwsA(isA<UnknownFailure>()),
    );
    stubGet('no es json');
    await expectLater(
      datasource.fetchModels(2020, 'Audi'),
      throwsA(isA<ParsingFailure>()),
    );
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
