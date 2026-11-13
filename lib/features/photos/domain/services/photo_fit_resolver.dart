import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/photo_fit_mode.dart';

/// Decide si una foto llena la tarjeta o se muestra completa.
class PhotoFitResolver {
  const PhotoFitResolver();

  /// Sin proporción o dentro del rango usa cover; fuera del rango, contain.
  PhotoFitMode resolve(double? aspectRatio) {
    if (aspectRatio == null) return PhotoFitMode.cover;
    final isInRange =
        aspectRatio >= UiConfig.photoCoverMinAspect &&
        aspectRatio <= UiConfig.photoCoverMaxAspect;
    return isInRange ? PhotoFitMode.cover : PhotoFitMode.contain;
  }
}
