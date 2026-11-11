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

  test('sin mensaje usa el nombre del tipo', () {
    final exception = DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.cancel,
    );
    expect(DioFailureMapper.map(exception).message, 'cancel');
  });
}
