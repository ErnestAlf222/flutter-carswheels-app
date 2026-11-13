import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/domain.dart';

/// Precarga en la caché de imágenes la foto grande de un modelo.
class PhotoPrefetcher {
  const PhotoPrefetcher({this.providerFor = _networkProvider});

  /// Proveedor de imagen por URL; las pruebas pueden cambiarlo.
  final ImageProvider Function(String url) providerFor;

  /// Descarga la foto en segundo plano e ignora cualquier error.
  Future<void> prefetchLarge(BuildContext context, PhotoEntity photo) async {
    try {
      await precacheImage(
        providerFor(photo.thumbnailUrl),
        context,
        // Sin esto Flutter reporta el error como excepción no capturada.
        onError: (error, stackTrace) {},
      );
    } on Object {
      // Una precarga fallida no debe afectar a quien la pidió.
    }
  }

  static ImageProvider _networkProvider(String url) =>
      CachedNetworkImageProvider(url, headers: PhotosConfig.requestHeaders);
}
