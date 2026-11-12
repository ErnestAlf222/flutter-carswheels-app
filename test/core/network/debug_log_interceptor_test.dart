import 'package:cars_wheels_app/core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// Adaptador simulado: responde 200 o falla según la ruta.
class _FakeAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('falla')) {
      return ResponseBody.fromString('no', 404);
    }
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

Dio _buildDio({required bool enableLogging}) {
  final dio = ApiClientFactory.create(
    baseUrl: 'https://example.test',
    acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
    userAgent: 'agente-prueba',
    sourceLabel: 'fuente',
    enableLogging: enableLogging,
  );
  dio.httpClientAdapter = _FakeAdapter();
  return dio;
}

void main() {
  late DebugPrintCallback originalDebugPrint;
  final captured = <String>[];

  setUp(() {
    captured.clear();
    originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) captured.add(message);
    };
  });

  tearDown(() => debugPrint = originalDebugPrint);

  test('con registro activo imprime una línea por petición', () async {
    final dio = _buildDio(enableLogging: true);
    await dio.get<dynamic>('/ok');
    expect(captured, hasLength(1));
    final line = captured.single;
    expect(line, startsWith('fuente | GET | https://example.test/ok | 200 | '));
    expect(line, matches(RegExp(r'\| \d+ ms \| UA: agente-prueba$')));
  });

  test('un error HTTP registra el código de estado', () async {
    final dio = _buildDio(enableLogging: true);
    await expectLater(dio.get<dynamic>('/falla'), throwsA(isA<DioException>()));
    expect(captured, hasLength(1));
    expect(captured.single, contains('| 404 |'));
  });

  test('con registro desactivado no imprime nada', () async {
    final dio = _buildDio(enableLogging: false);
    await dio.get<dynamic>('/ok');
    expect(captured, isEmpty);
  });
}
