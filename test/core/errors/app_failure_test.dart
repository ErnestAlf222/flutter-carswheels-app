import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fallas con mismo tipo y mensaje son iguales', () {
    expect(const NetworkFailure('a'), const NetworkFailure('a'));
  });

  test('fallas de distinto tipo no son iguales', () {
    expect(const NetworkFailure('a'), isNot(const ServerFailure('a')));
  });

  test('todas conservan su mensaje', () {
    const failures = <AppFailure>[
      NetworkFailure('m'),
      ServerFailure('m'),
      ParsingFailure('m'),
      UnknownFailure('m'),
      RateLimitFailure('m', retryAfterSeconds: 1),
    ];
    expect(failures.map((f) => f.message), everyElement('m'));
  });

  test('RateLimitFailure distingue los segundos de espera', () {
    expect(
      const RateLimitFailure('m', retryAfterSeconds: 1),
      isNot(const RateLimitFailure('m', retryAfterSeconds: 2)),
    );
  });
}
