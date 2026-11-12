import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

const String _artistHtml =
    '<a href="//commons.wikimedia.org/wiki/User:Areaseven" '
    'title="User:Areaseven">Areaseven</a>';

Map<String, dynamic> _page(String title, int index, {String? artist}) => {
  'pageid': index,
  'title': title,
  'index': index,
  'imageinfo': [
    {
      'thumburl': 'https://upload.example/thumb/$index.jpg',
      'descriptionurl': 'https://commons.example/wiki/$index',
      'extmetadata': {
        'Artist': {'value': artist ?? _artistHtml},
        'LicenseShortName': {'value': 'CC BY-SA 4.0'},
      },
    },
  ],
};

Map<String, dynamic> _response(List<Map<String, dynamic>> pages) => {
  'query': {
    'pages': {for (final page in pages) '${page['pageid']}': page},
  },
};

Response<Object?> _httpResponse(Object? data) => Response<Object?>(
  data: data,
  requestOptions: RequestOptions(path: '/x'),
);

void main() {
  final threePages = _response([
    _page('File:2020 Toyota Corolla LE 12-13-2019.jpg', 1),
    _page('File:2020 Toyota Corolla Cross - Front.jpg', 2),
    _page('File:Toyota Frontlander IMG001.jpg', 3),
  ]);

  group('CommonsSearchModel', () {
    test('lee las tres páginas aunque pages sea un objeto', () {
      expect(CommonsSearchModel.fromJson(threePages).pages, hasLength(3));
    });

    test('sin la clave query devuelve lista vacía', () {
      expect(CommonsSearchModel.fromJson({'batchcomplete': ''}).pages, isEmpty);
    });

    test('ignora páginas sin imageinfo', () {
      final json = _response([
        _page('File:A.jpg', 1),
        {'pageid': 2, 'title': 'File:B.jpg', 'index': 2},
      ]);
      expect(CommonsSearchModel.fromJson(json).pages, hasLength(1));
    });

    test('formas inválidas lanzan ParsingFailure', () {
      final invalidShapes = <Object?>[
        null,
        'texto',
        const <String>['a'],
        {'query': 'x'},
        {
          'query': {'pages': const <String>[]},
        },
        {
          'query': {
            'pages': {'1': 'x'},
          },
        },
        {
          'query': {
            'pages': {
              '1': {'imageinfo': 'x'},
            },
          },
        },
      ];
      for (final shape in invalidShapes) {
        expect(
          () => CommonsSearchModel.fromJson(shape),
          throwsA(isA<ParsingFailure>()),
        );
      }
    });
  });

  group('CommonsCandidateMapper', () {
    test('mapea título, miniatura, autor, licencia, fuente y rank', () {
      final page = CommonsSearchModel.fromJson(threePages).pages.first;
      final candidate = CommonsCandidateMapper.toCandidate(page);
      expect(candidate.title, 'File:2020 Toyota Corolla LE 12-13-2019.jpg');
      expect(candidate.thumbnailUrl, 'https://upload.example/thumb/1.jpg');
      expect(candidate.authorName, 'Areaseven');
      expect(candidate.licenseName, 'CC BY-SA 4.0');
      expect(candidate.sourceUrl, 'https://commons.example/wiki/1');
      expect(candidate.rank, 1);
    });

    test('decodifica entidades dentro del autor', () {
      final page = _page('File:A.jpg', 1, artist: 'Ford &amp; Sons &lt;3');
      expect(
        CommonsCandidateMapper.toCandidate(page).authorName,
        'Ford & Sons <3',
      );
    });

    test('no decodifica dos veces una entidad escapada', () {
      expect(CommonsCandidateMapper.cleanHtml('&amp;lt;'), '&lt;');
    });

    test('sin metadatos deja autor y licencia vacíos', () {
      final page = _page('File:A.jpg', 1);
      ((page['imageinfo'] as List<dynamic>).first as Map<String, dynamic>)
          .remove('extmetadata');
      final candidate = CommonsCandidateMapper.toCandidate(page);
      expect(candidate.authorName, isEmpty);
      expect(candidate.licenseName, isEmpty);
    });

    test('sin miniatura lanza ParsingFailure', () {
      final page = _page('File:A.jpg', 1);
      ((page['imageinfo'] as List<dynamic>).first as Map<String, dynamic>)
          .remove('thumburl');
      expect(
        () => CommonsCandidateMapper.toCandidate(page),
        throwsA(isA<ParsingFailure>()),
      );
    });
  });

  group('CommonsPhotosDatasource', () {
    late _MockDio dio;
    late RateLimitedQueue queue;
    late CommonsPhotosDatasource datasource;

    setUp(() {
      dio = _MockDio();
      queue = RateLimitedQueue(
        minInterval: Duration.zero,
        maxRetries: 0,
        wait: (_) async {},
      );
      datasource = CommonsPhotosDatasource(dio: dio, queue: queue);
    });

    tearDown(() => queue.close());

    test('manda los parámetros correctos y devuelve candidatas', () async {
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _httpResponse(threePages));
      final candidates = await datasource.searchCandidates('Toyota Corolla');
      expect(candidates, hasLength(3));
      final captured =
          verify(
                () => dio.get<Object?>(
                  ApiConfig.commonsApiUrl,
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured, {
        ...PhotosConfig.commonsRequestParameters,
        'gsrsearch': 'Toyota Corolla',
        'gsrlimit': PhotosConfig.searchResultLimit,
        'iiurlwidth': PhotosConfig.thumbnailWidthPixels,
      });
    });

    test('un 429 pasa por la cola y llega como RateLimitFailure', () async {
      final options = RequestOptions(path: '/x');
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response<Object?>(requestOptions: options, statusCode: 429),
        ),
      );
      await expectLater(
        datasource.searchCandidates('x'),
        throwsA(isA<RateLimitFailure>()),
      );
    });

    test('el repositorio delega en el datasource', () async {
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _httpResponse({'batchcomplete': ''}));
      final repository = PhotosRepositoryImpl(datasource);
      expect(await repository.searchCandidates('x'), isEmpty);
    });
  });
}
