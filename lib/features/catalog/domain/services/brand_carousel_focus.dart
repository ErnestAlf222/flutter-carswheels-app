import 'package:cars_wheels_app/core/config/config.dart';

/// Decide qué ventana del carrusel de marcas deja a la marca activa centrada.
class BrandCarouselFocus {
  const BrandCarouselFocus._();

  /// Marcas completas que caben en la ventana; si hay menos, no se desplaza.
  static int visibleOf(int count) => count < CarouselConfig.visibleBrandCount
      ? count
      : CarouselConfig.visibleBrandCount;

  /// Hay recorrido solo con más marcas que las visibles.
  static bool isScrollable(int count) =>
      count > CarouselConfig.visibleBrandCount;

  /// Primera marca de la ventana que deja a [selected] en la posición central.
  static int windowStartFor(int selected, int count) {
    if (count <= 0 || !isScrollable(count)) return 0;
    final start = selected - CarouselConfig.visibleBrandCount ~/ 2;
    return ((start % count) + count) % count;
  }

  /// La flecha de una dirección solo aparece si hay más marcas hacia allá.
  ///
  /// El carrusel da la vuelta: con recorrido siempre hay más en ambos lados.
  static bool hasMore(int count) => isScrollable(count);

  /// Posición virtual con la marca [target] más cercana a [current].
  static int nearestPosition({
    required int current,
    required int target,
    required int count,
  }) {
    if (count <= 0) return current;
    final delta = (((target - current) % count) + count) % count;
    return delta * 2 > count ? current + delta - count : current + delta;
  }
}
