import 'package:dio/dio.dart';

import 'package:cars_wheels_app/core/errors/errors.dart';

/// Convierte una DioException en un AppFailure.
class DioFailureMapper {
  const DioFailureMapper._();

  static AppFailure map(DioException exception) {
    final message = exception.message ?? exception.type.name;
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkFailure(message);
      case DioExceptionType.badResponse:
        return ServerFailure(message);
      case DioExceptionType.badCertificate:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return UnknownFailure(message);
    }
  }
}
