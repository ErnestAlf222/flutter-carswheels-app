import 'dart:io';

import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el archivo del loader existe en disco', () {
    expect(File(AssetsConfig.loaderGifPath).existsSync(), isTrue);
  });
}
