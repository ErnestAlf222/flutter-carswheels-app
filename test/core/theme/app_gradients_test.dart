import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el degradado primario usa los colores de AppColors', () {
    expect(AppGradients.primary.colors, [
      AppColors.gradientStart,
      AppColors.gradientEnd,
    ]);
  });
}
