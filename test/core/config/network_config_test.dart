import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('los valores de red son positivos', () {
    expect(NetworkConfig.maxConcurrentRequests, greaterThan(0));
    expect(NetworkConfig.commonsMinIntervalMilliseconds, greaterThan(0));
    expect(NetworkConfig.connectTimeoutSeconds, greaterThan(0));
    expect(NetworkConfig.receiveTimeoutSeconds, greaterThan(0));
  });
}
