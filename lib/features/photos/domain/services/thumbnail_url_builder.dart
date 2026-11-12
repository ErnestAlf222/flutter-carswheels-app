import 'package:cars_wheels_app/core/core.dart';

/// Cambia el ancho de una URL de miniatura de Commons.
class ThumbnailUrlBuilder {
  const ThumbnailUrlBuilder();

  static final RegExp _widthSegment = RegExp(
    PhotosConfig.thumbnailWidthSegmentPattern,
  );

  /// Misma URL con el ancho dado; sin segmento de ancho, la devuelve igual.
  String forUrl(String thumbnailUrl, int width) {
    final segment = PhotosConfig.thumbnailWidthSegmentFormat.replaceFirst(
      PhotosConfig.thumbnailWidthPlaceholder,
      '$width',
    );
    return thumbnailUrl.replaceFirst(_widthSegment, segment);
  }
}
