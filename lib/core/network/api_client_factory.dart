import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/network/debug_log_interceptor.dart';

/// Crea clientes Dio con la configuración común de red.
class ApiClientFactory {
  const ApiClientFactory._();

  static Dio create({
    required String baseUrl,
    required String acceptHeaderValue,
    required String userAgent,
    required String sourceLabel,
    bool enableLogging = kDebugMode,
  }) {
    final dio = Dio(
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
    if (enableLogging) {
      dio.interceptors.add(DebugLogInterceptor(sourceLabel: sourceLabel));
    }
    return dio;
  }
}
