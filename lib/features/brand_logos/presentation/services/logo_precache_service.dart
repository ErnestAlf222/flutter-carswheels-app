import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/domain.dart';
import 'package:cars_wheels_app/features/brand_logos/presentation/loaders/loaders.dart';

/// Descarga un logo y lo deja en la caché que usa BrandLogoWidget.
class LogoPrecacheService {
  const LogoPrecacheService({this.store});

  /// Disco de logos: lo que se precarga queda guardado para usarse sin red.
  final LogoFileStore? store;

  /// Precarga el logo en [url]; un fallo de red se ignora.
  Future<void> precache(BuildContext context, String url) async {
    if (url.endsWith(LogosConfig.svgExtension)) {
      try {
        // Llena svg.cache con la misma llave que usa SvgPicture y guarda en disco.
        await DiskFirstSvgLoader(
          url,
          headers: LogosConfig.requestHeaders,
          store: store,
          fileName: const LogoFileNamer().svgFileNameFor(url),
        ).loadBytes(null);
      } catch (_) {
        // Sin red el logo se descargará al mostrarse.
      }
      return;
    }
    await precacheImage(
      CachedNetworkImageProvider(url, headers: LogosConfig.requestHeaders),
      context,
      onError: (_, _) {},
    );
  }
}
