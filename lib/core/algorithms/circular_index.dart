import 'package:cars_wheels_app/core/config/carousel_config.dart';

/// Índices de un carrusel circular: páginas virtuales que dan la vuelta.
class CircularIndex {
  const CircularIndex._();

  /// Índice real (0..count-1) de una página virtual; con una foto, siempre 0.
  static int wrap(int page, int count) => count <= 1 ? 0 : page % count;

  /// Página virtual inicial del índice real, lejos de ambos bordes.
  static int initialPage(int index, int count) =>
      count <= 1 ? 0 : CarouselConfig.circularPageBase * count + index;

  /// Cantidad de páginas del PageView: nulo (sin fin) si hay vuelta, 1 si no.
  static int? pageCount(int count) => count <= 1 ? 1 : null;

  /// Índice real de la foto siguiente, dando la vuelta al final.
  static int next(int index, int count) => count <= 1 ? 0 : (index + 1) % count;
}
