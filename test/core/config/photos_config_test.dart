import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('excludedTitleWords no está vacía ni tiene duplicados', () {
    const words = PhotosConfig.excludedTitleWords;
    expect(words, isNotEmpty);
    expect(words.toSet().length, words.length);
  });

  test('los reintentos y las esperas son positivos', () {
    expect(PhotosConfig.maxRetryAttempts, greaterThan(0));
    expect(PhotosConfig.defaultRetryAfterSeconds, greaterThan(0));
  });

  test('los parámetros fijos de Commons incluyen la acción de búsqueda', () {
    expect(PhotosConfig.commonsRequestParameters['generator'], 'search');
    expect(PhotosConfig.photoModelStripTokens, contains('4WD'));
  });

  test('searchResultLimit es positivo', () {
    expect(PhotosConfig.searchResultLimit, greaterThan(0));
  });
}
