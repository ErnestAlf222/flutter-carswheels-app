import 'package:cars_wheels_app/core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _exception(DioExceptionType type) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  type: type,
  message: 'detalle',
);

void main() {
  const networkTypes = [
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  ];
  for (final type in networkTypes) {
    test('$type produce NetworkFailure', () {
      expect(
        DioFailureMapper.map(_exception(type)),
        const NetworkFailure('detalle'),
      );
    });
  }

  test('badResponse produce ServerFailure', () {
    expect(
      DioFailureMapper.map(_exception(DioExceptionType.badResponse)),
      const ServerFailure('detalle'),
    );
  });

  const unknownTypes = [
    DioExceptionType.cancel,
    DioExceptionType.badCertificate,
    DioExceptionType.unknown,
    DioExceptionType.transformTimeout,
  ];
  for (final type in unknownTypes) {
    test('$type produce UnknownFailure', () {
      expect(
        DioFailureMapper.map(_exception(type)),
        const UnknownFailure('detalle'),
      );
    });
  }

  group('HTTP 429', () {
    DioException tooManyRequests(Map<String, List<String>> headers) {
      final options = RequestOptions(path: '/x');
      return DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        message: 'limite',
        response: Response<Object?>(
          requestOptions: options,
          statusCode: 429,
          headers: Headers.fromMap(headers),
        ),
      );
    }

    test('con cabecera numérica usa sus segundos', () {
      final failure = DioFailureMapper.map(
        tooManyRequests({
          PhotosConfig.retryAfterHeaderName: ['18'],
        }),
      );
      expect(failure, const RateLimitFailure('limite', retryAfterSeconds: 18));
    });

    test('sin cabecera usa el valor por defecto', () {
      final failure = DioFailureMapper.map(tooManyRequests({}));
      expect(
        failure,
        const RateLimitFailure(
          'limite',
          retryAfterSeconds: PhotosConfig.defaultRetryAfterSeconds,
        ),
      );
    });

    test('con cabecera no numérica usa el valor por defecto', () {
      final failure = DioFailureMapper.map(
        tooManyRequests({
          PhotosConfig.retryAfterHeaderName: ['pronto'],
        }),
      );
      expect(
        (failure as RateLimitFailure).retryAfterSeconds,
        PhotosConfig.defaultRetryAfterSeconds,
      );
    });
  });

  test('sin mensaje usa el nombre del tipo', () {
    final exception = DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.cancel,
    );
    expect(DioFailureMapper.map(exception).message, 'cancel');
  });
}
