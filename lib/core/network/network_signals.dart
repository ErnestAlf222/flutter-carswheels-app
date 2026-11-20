import 'dart:async';

import 'package:dio/dio.dart';

/// Lo que una petición de red dice sobre la conexión.
enum NetworkSignal {
  /// Hubo respuesta del servidor (aunque sea un error HTTP): hay conexión.
  reachable,

  /// No se pudo abrir la conexión (sin red, sin DNS).
  unreachable,

  /// Tiempo de espera agotado: puede ser el servidor o la red.
  slow,
}

/// Canal por donde las peticiones avisan el estado de la conexión.
class NetworkSignals {
  NetworkSignals() : _controller = StreamController<NetworkSignal>.broadcast();

  final StreamController<NetworkSignal> _controller;

  Stream<NetworkSignal> get stream => _controller.stream;

  void report(NetworkSignal signal) {
    if (!_controller.isClosed) _controller.add(signal);
  }

  Future<void> close() => _controller.close();

  /// Señal que corresponde a una falla de dio; nula si no habla de la conexión.
  static NetworkSignal? fromException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionError:
        return NetworkSignal.unreachable;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkSignal.slow;
      case DioExceptionType.badResponse:
        return NetworkSignal.reachable;
      case DioExceptionType.badCertificate:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return null;
    }
  }
}

/// Interceptor que reporta a [NetworkSignals] las respuestas y las fallas de red.
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this.signals);

  final NetworkSignals signals;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    signals.report(NetworkSignal.reachable);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final signal = NetworkSignals.fromException(err);
    if (signal != null) signals.report(signal);
    handler.next(err);
  }
}
