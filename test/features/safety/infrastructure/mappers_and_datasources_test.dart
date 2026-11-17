import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/nhtsa_fixtures.dart';

class _MockDio extends Mock implements Dio {}

Response<Object?> _ok(Object? data) => Response<Object?>(
  data: data,
  requestOptions: RequestOptions(path: '/x'),
);

DioException _status(int code, Object? data) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  type: DioExceptionType.badResponse,
  response: Response<Object?>(
    data: data,
    statusCode: code,
    requestOptions: RequestOptions(path: '/x'),
  ),
);

Map<String, dynamic> _first(Map<String, dynamic> json) =>
    (json['Results'] as List<dynamic>).first as Map<String, dynamic>;

void main() {
  group('SafetyRatingMapper', () {
    test('X5 AWD: las cuatro estrellas', () {
      expect(
        SafetyRatingMapper.toEntity(_first(bmwX5AwdRatingJson)),
        const SafetyRatingEntity(overall: 4, front: 4, side: 5, rollover: 4),
      );
    });

    test('X5 RWD: "Not Rated" es nulo y lo demás se conserva', () {
      expect(
        SafetyRatingMapper.toEntity(_first(bmwX5RwdRatingJson)),
        const SafetyRatingEntity(front: 4, side: 5),
      );
    });

    test('Tesla Model 3: todo "Not Rated" es nulo', () {
      expect(
        SafetyRatingMapper.toEntity(_first(tesla3RatingJson)),
        const SafetyRatingEntity(),
      );
    });

    test('vacío, 0 o fuera de 1 a 5 es nulo', () {
      expect(SafetyRatingMapper.parseStars(''), isNull);
      expect(SafetyRatingMapper.parseStars(null), isNull);
      expect(SafetyRatingMapper.parseStars('0'), isNull);
      expect(SafetyRatingMapper.parseStars('6'), isNull);
      expect(SafetyRatingMapper.parseStars('5'), 5);
    });
  });

  group('RecallMapper y modelo de resultados', () {
    test('Camry: campos y fecha dd/MM/yyyy', () {
      final results = NhtsaResultsModel.fromJson(
        camryRecallsJson,
        SafetyConfig.recallsResultsKey,
      ).results;
      final recall = RecallMapper.toEntity(results.first)!;
      expect(recall.campaignNumber, '24V128000');
      expect(recall.reportDate, DateTime.utc(2024, 2, 22));
      expect(recall.component, 'SEATS');
    });

    test('sin número de campaña no hay recall', () {
      expect(RecallMapper.toEntity(const {'Component': 'X'}), isNull);
    });

    test('una respuesta sin la forma esperada es ParsingFailure', () {
      expect(
        () => NhtsaResultsModel.fromJson('texto', 'Results'),
        throwsA(isA<ParsingFailure>()),
      );
      expect(
        () => NhtsaResultsModel.fromJson(const {'otra': 1}, 'Results'),
        throwsA(isA<ParsingFailure>()),
      );
    });
  });

  group('NhtsaApiSafetyRatingsDatasource', () {
    late _MockDio dio;
    late NhtsaApiSafetyRatingsDatasource datasource;

    setUp(() {
      dio = _MockDio();
      datasource = NhtsaApiSafetyRatingsDatasource(
        dio: dio,
        queue: ConcurrencyLimitedQueue(maxConcurrent: 10),
      );
    });

    test('codifica la marca y devuelve los nombres de modelo', () async {
      when(() => dio.get<Object?>(any())).thenAnswer(
        (_) async => _ok({
          'Results': [
            for (final name in tesla2024Models) {'Model': name},
          ],
        }),
      );
      final names = await datasource.fetchModelNames(2024, 'Aston Martin');
      expect(names, tesla2024Models);
      verify(
        () => dio.get<Object?>(
          '/SafetyRatings/modelyear/2024/make/Aston%20Martin',
        ),
      ).called(1);
    });

    test('descarta el VehicleId 0 de los modelos sin calificación', () async {
      when(() => dio.get<Object?>(any())).thenAnswer(
        (_) async => _ok({
          'Results': [
            {'VehicleDescription': 'a', 'VehicleId': 0},
            ...(bmwX5VariantsJson['Results'] as List<dynamic>),
          ],
        }),
      );
      expect(await datasource.fetchVehicleIds(2024, 'BMW', 'X5'), [
        19227,
        19226,
      ]);
    });

    test('un error HTTP se traduce a AppFailure', () async {
      when(() => dio.get<Object?>(any())).thenThrow(_status(500, null));
      expect(datasource.fetchRating(1), throwsA(isA<ServerFailure>()));
    });
  });

  group('NhtsaApiRecallsDatasource', () {
    late _MockDio apiDio;
    late _MockDio vpicDio;
    late NhtsaApiRecallsDatasource datasource;

    setUp(() {
      apiDio = _MockDio();
      vpicDio = _MockDio();
      datasource = NhtsaApiRecallsDatasource(
        apiDio: apiDio,
        vpicDio: vpicDio,
        queue: ConcurrencyLimitedQueue(maxConcurrent: 10),
      );
    });

    void stubRecalls(Object? Function() answer) {
      when(
        () => apiDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok(answer()));
    }

    test('lee la lista "results" en minúscula', () async {
      stubRecalls(() => camryRecallsJson);
      final recalls = await datasource.fetchRecalls(2024, 'Toyota', 'Camry');
      expect(recalls, hasLength(1));
      expect(recalls.single.campaignNumber, '24V128000');
    });

    test('HTTP 400 con Count 0 es lista vacía, no un fallo', () async {
      when(
        () => apiDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(_status(400, noRecallsBodyJson));
      expect(await datasource.fetchRecalls(2027, 'Audi', 'Q5'), isEmpty);
    });

    test('HTTP 400 sin Count 0 sigue siendo un fallo', () async {
      when(
        () => apiDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(_status(400, 'Bad Request'));
      expect(
        datasource.fetchRecalls(2027, 'Audi', 'Q5'),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('vPIC: nombres de modelo del año', () async {
      when(
        () => vpicDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok({
          'Results': [
            for (final name in vpicAstonMartin2027Models) {'Model_Name': name},
          ],
        }),
      );
      expect(
        await datasource.fetchVpicModelNames(2027, 'Aston Martin'),
        vpicAstonMartin2027Models,
      );
    });
  });
}
