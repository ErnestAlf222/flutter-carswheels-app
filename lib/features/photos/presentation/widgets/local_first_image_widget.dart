import 'dart:io';

import 'package:flutter/widgets.dart';

/// Imagen del archivo local; sin archivo, o si no se puede leer, usa la de red.
class LocalFirstImageWidget extends StatelessWidget {
  const LocalFirstImageWidget({
    super.key,
    required this.localPath,
    required this.networkBuilder,
    required this.fit,
    this.cacheWidth,
  });

  /// Ruta del archivo guardado; nula si la foto solo tiene URL.
  final String? localPath;

  /// Imagen de respaldo que baja de la red.
  final WidgetBuilder networkBuilder;
  final BoxFit fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final path = localPath;
    if (path == null) return networkBuilder(context);
    return Image.file(
      File(path),
      fit: fit,
      alignment: Alignment.center,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      errorBuilder: (context, _, _) => networkBuilder(context),
    );
  }
}
