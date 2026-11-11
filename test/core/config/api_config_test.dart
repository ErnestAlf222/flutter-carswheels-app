import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('todas las URLs son absolutas y https', () {
    const urls = [
      ApiConfig.fuelEconomyBaseUrl,
      ApiConfig.nhtsaVpicBaseUrl,
      ApiConfig.nhtsaApiBaseUrl,
      ApiConfig.conueeApiBaseUrl,
      ApiConfig.commonsApiUrl,
    ];
    for (final url in urls) {
      final uri = Uri.parse(url);
      expect(uri.isAbsolute, isTrue, reason: url);
      expect(uri.scheme, 'https', reason: url);
    }
  });

  test('conueeDatasetId no está vacío', () {
    expect(ApiConfig.conueeDatasetId, isNotEmpty);
  });
}
