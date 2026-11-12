import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Imprime una línea por petición para depurar el tráfico de red.
class DebugLogInterceptor extends Interceptor {
  DebugLogInterceptor({required this.sourceLabel});

  final String sourceLabel;

  // Clave donde se guarda el instante de inicio de cada petición.
  static const String _startKey = 'debugLogStartMicros';
  static const int _microsPerMilli = 1000;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().microsecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(response.requestOptions, '${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    _log(err.requestOptions, status?.toString() ?? err.type.name);
    handler.next(err);
  }

  void _log(RequestOptions options, String outcome) {
    final startMicros = options.extra[_startKey] as int?;
    final elapsedMillis = startMicros == null
        ? 0
        : (DateTime.now().microsecondsSinceEpoch - startMicros) ~/
              _microsPerMilli;
    final userAgent = options.headers[HttpHeaders.userAgentHeader];
    debugPrint(
      '$sourceLabel | ${options.method} | ${options.uri} | $outcome | '
      '$elapsedMillis ms | UA: $userAgent',
    );
  }
}
