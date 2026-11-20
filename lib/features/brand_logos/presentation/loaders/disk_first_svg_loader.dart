import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/domain.dart';
import 'package:cars_wheels_app/features/brand_logos/presentation/loaders/sanitized_svg_network_loader.dart';

/// Carga el SVG ya saneado desde el disco y solo va a la red si no está.
///
/// La URL lleva la versión fijada del logo, así que lo guardado no caduca: una
/// versión nueva es otro archivo. Un archivo dañado se descarta y se vuelve a pedir.
class DiskFirstSvgLoader extends SanitizedSvgNetworkLoader {
  const DiskFirstSvgLoader(
    super.url, {
    super.headers,
    super.theme,
    super.colorMapper,
    super.httpClient,
    super.sanitizer,
    this.store,
    this.fileName,
  });

  /// Disco de logos; sin él se comporta como el cargador de red.
  final LogoFileStore? store;

  /// Nombre del archivo del logo; nulo si esta URL no se guarda.
  final String? fileName;

  @override
  Future<Uint8List?> prepareMessage(BuildContext? context) async {
    final disk = store;
    final name = fileName;
    if (disk == null || name == null) return super.prepareMessage(context);
    final saved = await disk.read(name);
    if (saved != null) {
      if (saved.contains(LogoDiskConfig.svgOpenMarker)) {
        return Uint8List.fromList(utf8.encode(saved));
      }
      await disk.discard(name);
    }
    final bytes = await downloadSvg();
    if (bytes != null) {
      final clean = sanitizer.sanitize(
        utf8.decode(bytes, allowMalformed: true),
      );
      if (clean.contains(LogoDiskConfig.svgOpenMarker)) {
        unawaited(disk.write(name, clean));
      }
    }
    return bytes;
  }

  /// Baja el SVG de la red; aparte para que las pruebas no necesiten red.
  @protected
  Future<Uint8List?> downloadSvg() => super.prepareMessage(null);
}
