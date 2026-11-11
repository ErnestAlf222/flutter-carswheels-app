import 'dart:io';

import 'package:dio/dio.dart';

import 'package:cars_wheels_app/core/config/config.dart';

/// Crea clientes Dio con la configuración común de red.
class ApiClientFactory {
  const ApiClientFactory._();

  static Dio create({
    required String baseUrl,
    required String acceptHeaderValue,
    required String userAgent,
  }) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(
          seconds: NetworkConfig.connectTimeoutSeconds,
        ),
        receiveTimeout: const Duration(
          seconds: NetworkConfig.receiveTimeoutSeconds,
        ),
        headers: {
          Headers.acceptHeader: acceptHeaderValue,
          HttpHeaders.userAgentHeader: userAgent,
        },
      ),
    );
  }
}
