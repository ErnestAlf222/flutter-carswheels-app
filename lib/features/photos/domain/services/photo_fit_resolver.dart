import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/photo_fit_mode.dart';

/// Decide si una foto llena la tarjeta o se muestra completa.
class PhotoFitResolver {
  const PhotoFitResolver();

  /// Una foto es pequeña o delgada si su imagen decodificada queda bajo el umbral.
  ///
  /// Sin tamaño conocido nunca se considera pequeña.
  bool isSmall(int? widthPixels, int? heightPixels) =>
      widthPixels != null &&
      heightPixels != null &&
      (widthPixels < UiConfig.photoSmallMinWidthPixels ||
          heightPixels < UiConfig.photoSmallMinHeightPixels);

  /// Pequeña o con proporción fuera del rango: contain; si no, cover.
  ///
  /// Sin proporción ni tamaño usa cover.
  PhotoFitMode resolve(
    double? aspectRatio, {
    int? widthPixels,
    int? heightPixels,
  }) {
    if (isSmall(widthPixels, heightPixels)) return PhotoFitMode.contain;
    if (aspectRatio == null) return PhotoFitMode.cover;
    final isInRange =
        aspectRatio >= UiConfig.photoCoverMinAspect &&
        aspectRatio <= UiConfig.photoCoverMaxAspect;
    return isInRange ? PhotoFitMode.cover : PhotoFitMode.contain;
  }

  /// Escala (píxeles lógicos por píxel de la foto) para mostrarla completa sin
  /// ampliarla más allá del tope configurado.
  double displayScale({
    required double boxWidth,
    required double boxHeight,
    required int widthPixels,
    required int heightPixels,
  }) {
    final fit = boxWidth / widthPixels < boxHeight / heightPixels
        ? boxWidth / widthPixels
        : boxHeight / heightPixels;
    return fit < UiConfig.photoMaxDisplayScale
        ? fit
        : UiConfig.photoMaxDisplayScale;
  }
}
