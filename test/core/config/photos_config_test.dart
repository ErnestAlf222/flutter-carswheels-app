import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('excludedTitleWords no está vacía ni tiene duplicados', () {
    const words = PhotosConfig.excludedTitleWords;
    expect(words, isNotEmpty);
    expect(words.toSet().length, words.length);
  });

  test('searchResultLimit es positivo', () {
    expect(PhotosConfig.searchResultLimit, greaterThan(0));
  });
}
