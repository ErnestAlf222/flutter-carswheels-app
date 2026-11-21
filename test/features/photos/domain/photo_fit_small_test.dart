import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = PhotoFitResolver();

  test(
    'bajo el umbral de ancho o de alto la foto es pequeña y va completa',
    () {
      expect(
        resolver.resolve(
          1.5,
          widthPixels: UiConfig.photoSmallMinWidthPixels - 1,
          heightPixels: 900,
        ),
        PhotoFitMode.contain,
      );
      expect(
        resolver.resolve(
          1.5,
          widthPixels: 900,
          heightPixels: UiConfig.photoSmallMinHeightPixels - 1,
        ),
        PhotoFitMode.contain,
      );
    },
  );

  test('una foto grande con proporción normal sigue llenando', () {
    expect(
      resolver.resolve(1.5, widthPixels: 960, heightPixels: 640),
      PhotoFitMode.cover,
    );
  });

  test('sin tamaño conocido nunca es pequeña y decide la proporción', () {
    expect(resolver.isSmall(null, 200), isFalse);
    expect(resolver.resolve(1.5), PhotoFitMode.cover);
    expect(resolver.resolve(3.0), PhotoFitMode.contain);
  });

  test('la ampliación de una foto pequeña tiene tope', () {
    final scale = resolver.displayScale(
      boxWidth: 400,
      boxHeight: 316,
      widthPixels: 200,
      heightPixels: 150,
    );
    expect(scale, UiConfig.photoMaxDisplayScale);
    final shrink = resolver.displayScale(
      boxWidth: 100,
      boxHeight: 316,
      widthPixels: 200,
      heightPixels: 150,
    );
    expect(shrink, closeTo(0.5, 0.001));
  });
}
