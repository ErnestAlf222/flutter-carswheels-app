import 'package:dio/dio.dart';

import 'package:cars_wheels_app/features/connectivity/domain/domain.dart';

/// Sonda HEAD sin cuerpo: cualquier respuesta HTTP cuenta como conexión.
class DioConnectionProbe implements ConnectionProbe {
  const DioConnectionProbe({
    required this.dio,
    required this.url,
    required this.timeout,
  });

  final Dio dio;
  final String url;
  final Duration timeout;

  @override
  Future<bool> isReachable() async {
    try {
      await dio.head<void>(
        url,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
          validateStatus: (_) => true,
        ),
      );
      return true;
    } on DioException catch (exception) {
      // Un error HTTP ya significa que hay red; lo demás, que no.
      return exception.type == DioExceptionType.badResponse;
    }
  }
}
