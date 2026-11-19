import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/conuee_fixtures.dart';

class _MockDio extends Mock implements Dio {}

Response<Object?> _ok(Object? data) => Response<Object?>(
  data: data,
  requestOptions: RequestOptions(path: '/x'),
);

Map<String, dynamic> _package(List<Map<String, dynamic>> resources) => {
  'success': true,
  'result': {'resources': resources},
};

Map<String, dynamic> _resource(String id, String name, {bool active = true}) =>
    {'id': id, 'name': name, 'datastore_active': active};

Map<String, dynamic> _page(int total, List<Map<String, dynamic>> records) => {
  'success': true,
  'result': {'total': total, 'records': records},
};

void main() {
  late _MockDio dio;
  late ConcurrencyLimitedQueue queue;
  late ConueeApiDatasource datasource;

  setUp(() {
    dio = _MockDio();
    queue = ConcurrencyLimitedQueue(maxConcurrent: 2);
    datasource = ConueeApiDatasource(dio: dio, queue: queue);
  });

  tearDown(() => queue.close());

  group('fetchYearSources', () {
    test(
      'ofrece todo año con datastore activo, del más reciente al más antiguo',
      () async {
        when(
          () => dio.get<Object?>(
            ConueeConfig.packageShowPath,
            queryParameters: {
              ConueeConfig.packageIdParameter: ApiConfig.conueeDatasetId,
            },
          ),
        ).thenAnswer(
          (_) async => _ok(
            _package([
              _resource('r25', 'Catálogo de rendimiento (2025)'),
              _resource('r26', 'Catálogo de rendimiento (2026)'),
              _resource('r24', 'Catálogo de rendimiento (2024)'),
              _resource('rx', 'Sin año'),
              _resource('ri', 'Catálogo (2027)', active: false),
            ]),
          ),
        );
        expect(await datasource.fetchYearSources(), const [
          MxYearSourceEntity(year: 2026, resourceId: 'r26'),
          MxYearSourceEntity(year: 2025, resourceId: 'r25'),
          MxYearSourceEntity(year: 2024, resourceId: 'r24'),
        ]);
      },
    );

    test('una respuesta sin recursos es ParsingFailure', () async {
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok({'success': true}));
      expect(datasource.fetchYearSources(), throwsA(isA<ParsingFailure>()));
    });

    test('un error HTTP se convierte en AppFailure', () async {
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(datasource.fetchYearSources(), throwsA(isA<NetworkFailure>()));
    });
  });

  group('fetchYear', () {
    const source = MxYearSourceEntity(year: 2025, resourceId: 'r25');
    final rows = conueeFixtureRows.take(3).toList();

    test(
      'una sola petición con el tope de config cuando el total cabe',
      () async {
        when(
          () => dio.get<Object?>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => _ok(_page(3, rows)));
        final catalog = await datasource.fetchYear(source);
        expect(catalog.year, 2025);
        expect(catalog.rawRowCount, 3);
        final captured = verify(
          () => dio.get<Object?>(
            ConueeConfig.datastoreSearchPath,
            queryParameters: captureAny(named: 'queryParameters'),
          ),
        ).captured;
        expect(captured, [
          {
            ConueeConfig.resourceIdParameter: 'r25',
            ConueeConfig.limitParameter: ConueeConfig.maxRecordsPerRequest,
            ConueeConfig.offsetParameter: 0,
          },
        ]);
      },
    );

    test('pagina con offset solo si el total supera lo recibido', () async {
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((invocation) async {
        final query =
            invocation.namedArguments[#queryParameters] as Map<String, Object>;
        final offset = query[ConueeConfig.offsetParameter] as int;
        return _ok(
          _page(3, offset == 0 ? rows.sublist(0, 2) : rows.sublist(2)),
        );
      });
      final catalog = await datasource.fetchYear(source);
      expect(catalog.rawRowCount, 3);
      final offsets =
          verify(
            () => dio.get<Object?>(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            ),
          ).captured.map(
            (q) => (q as Map<String, Object>)[ConueeConfig.offsetParameter],
          );
      expect(offsets, [0, 2]);
    });

    test('una página vacía corta la paginación', () async {
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok(_page(10, const [])));
      expect((await datasource.fetchYear(source)).rawRowCount, 0);
      verify(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });
  });
}
