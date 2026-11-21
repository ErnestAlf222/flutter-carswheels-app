import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('windowStartFor', () {
    test('deja la marca activa en la posición central de la ventana', () {
      const slot = CarouselConfig.visibleBrandCount ~/ 2;
      expect(BrandCarouselFocus.windowStartFor(7, 10), 7 - slot);
    });

    test('da la vuelta cuando la activa está al principio', () {
      const slot = CarouselConfig.visibleBrandCount ~/ 2;
      expect(BrandCarouselFocus.windowStartFor(0, 10), 10 - slot);
    });

    test('con pocas marcas no hay desplazamiento', () {
      expect(
        BrandCarouselFocus.windowStartFor(2, CarouselConfig.visibleBrandCount),
        0,
      );
      expect(BrandCarouselFocus.windowStartFor(0, 0), 0);
    });
  });

  group('nearestPosition', () {
    test('elige la copia más cercana de la marca', () {
      expect(
        BrandCarouselFocus.nearestPosition(current: 1003, target: 5, count: 10),
        1005,
      );
      expect(
        BrandCarouselFocus.nearestPosition(current: 1000, target: 9, count: 10),
        999,
      );
      expect(
        BrandCarouselFocus.nearestPosition(current: 1002, target: 2, count: 10),
        1002,
      );
    });
  });

  group('flechas', () {
    test('solo hay más marcas hacia los lados si hay recorrido', () {
      expect(BrandCarouselFocus.hasMore(10), isTrue);
      expect(
        BrandCarouselFocus.hasMore(CarouselConfig.visibleBrandCount),
        isFalse,
      );
    });
  });
}
