import 'dart:io';

import 'package:cars_wheels_app/core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('crea un Dio con URL base, tiempos y cabeceras', () {
    final dio = ApiClientFactory.create(
      baseUrl: 'https://example.test/api',
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: 'agente-prueba',
      sourceLabel: 'prueba',
      enableLogging: false,
    );
    expect(dio.options.baseUrl, 'https://example.test/api');
    expect(
      dio.options.connectTimeout,
      const Duration(seconds: NetworkConfig.connectTimeoutSeconds),
    );
    expect(
      dio.options.receiveTimeout,
      const Duration(seconds: NetworkConfig.receiveTimeoutSeconds),
    );
    expect(
      dio.options.headers[Headers.acceptHeader],
      NetworkConfig.jsonAcceptHeaderValue,
    );
    expect(dio.options.headers[HttpHeaders.userAgentHeader], 'agente-prueba');
  });
}
