import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _CountingDatasource implements BrandLogosDatasource {
  int calls = 0;

  @override
  Future<Map<String, String>> fetchManifest() async {
    calls++;
    return {'Alfa Romeo': 'alfa-romeo-logo.svg', 'Citroën': 'citroen-logo.png'};
  }
}

Response<Object?> _response(Object? data) => Response<Object?>(
  data: data,
  requestOptions: RequestOptions(path: '/x'),
);

void main() {
  group('BrandLogosManifestModel', () {
    test('acepta un mapa de textos', () {
      final model = BrandLogosManifestModel.fromJson({'A': 'a.svg'});
      expect(model.fileNamesByBrand, {'A': 'a.svg'});
    });

    test('acepta un mapa vacío', () {
      expect(BrandLogosManifestModel.fromJson({}).fileNamesByBrand, isEmpty);
    });

    test('formas inválidas lanzan ParsingFailure', () {
      final invalidShapes = <Object?>[
        null,
        'texto',
        const <String>['a'],
        {'A': 1},
        {'A': null},
      ];
      for (final shape in invalidShapes) {
        expect(
          () => BrandLogosManifestModel.fromJson(shape),
          throwsA(isA<ParsingFailure>()),
        );
      }
    });
  });

  group('BrandLogosMapper', () {
    test('normaliza el nombre y arma la URL completa', () {
      final urls = BrandLogosMapper.toLogoUrls({
        'Alfa Romeo': 'alfa-romeo-logo.svg',
      });
      expect(urls, {
        'alfaromeo': '${LogosConfig.logosBaseUrl}alfa-romeo-logo.svg',
      });
    });

    test('un mapa vacío da un mapa vacío', () {
      expect(BrandLogosMapper.toLogoUrls({}), isEmpty);
    });
  });

  group('BrandLogosCdnDatasource', () {
    late _MockDio dio;
    late BrandLogosCdnDatasource datasource;

    setUp(() {
      dio = _MockDio();
      datasource = BrandLogosCdnDatasource(dio);
    });

    test('pide el manifiesto a la URL configurada', () async {
      when(() => dio.get<Object?>(any()))
          .thenAnswer((_) async => _response({'A': 'a.svg'}));
      expect(await datasource.fetchManifest(), {'A': 'a.svg'});
      verify(
        () => dio.get<Object?>(
          '${LogosConfig.logosBaseUrl}${LogosConfig.manifestFileName}',
        ),
      ).called(1);
    });

    test('una respuesta inválida lanza ParsingFailure', () async {
      when(() => dio.get<Object?>(any()))
          .thenAnswer((_) async => _response('no es json'));
      await expectLater(
        datasource.fetchManifest(),
        throwsA(isA<ParsingFailure>()),
      );
    });

    test('un error de Dio se convierte en AppFailure', () async {
      when(() => dio.get<Object?>(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionError,
        ),
      );
      await expectLater(
        datasource.fetchManifest(),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('BrandLogosRepositoryImpl', () {
    test('devuelve URLs completas con la marca normalizada', () async {
      final repository = BrandLogosRepositoryImpl(_CountingDatasource());
      final urls = await repository.getLogoUrlsByBrand();
      expect(
        urls['alfaromeo'],
        '${LogosConfig.logosBaseUrl}alfa-romeo-logo.svg',
      );
      expect(urls['citroen'], '${LogosConfig.logosBaseUrl}citroen-logo.png');
    });

    test('consulta el manifiesto una sola vez', () async {
      final datasource = _CountingDatasource();
      final repository = BrandLogosRepositoryImpl(datasource);
      await repository.getLogoUrlsByBrand();
      await repository.getLogoUrlsByBrand();
      expect(datasource.calls, 1);
    });
  });
}
