import 'package:dio/dio.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/errors/errors.dart';

/// Convierte una DioException en un AppFailure.
class DioFailureMapper {
  const DioFailureMapper._();

  static const int _tooManyRequestsStatus = 429;

  static AppFailure map(DioException exception) {
    final message = exception.message ?? exception.type.name;
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkFailure(message);
      case DioExceptionType.badResponse:
        if (exception.response?.statusCode == _tooManyRequestsStatus) {
          return RateLimitFailure(
            message,
            retryAfterSeconds: _readRetryAfterSeconds(exception.response),
          );
        }
        return ServerFailure(message);
      case DioExceptionType.badCertificate:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return UnknownFailure(message);
    }
  }

  // Segundos de la cabecera de espera o el valor por defecto.
  static int _readRetryAfterSeconds(Response<dynamic>? response) {
    final raw = response?.headers.value(PhotosConfig.retryAfterHeaderName);
    return int.tryParse(raw ?? '') ?? PhotosConfig.defaultRetryAfterSeconds;
  }
}
