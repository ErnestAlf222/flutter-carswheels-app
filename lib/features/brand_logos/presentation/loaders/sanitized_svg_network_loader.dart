import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:cars_wheels_app/features/brand_logos/domain/domain.dart';

/// Descarga un SVG y lo sanea antes de que flutter_svg lo analice.
class SanitizedSvgNetworkLoader extends SvgNetworkLoader {
  const SanitizedSvgNetworkLoader(
    super.url, {
    super.headers,
    super.theme,
    super.colorMapper,
    super.httpClient,
    this.sanitizer = const SvgSanitizer(),
  });

  final SvgSanitizer sanitizer;

  @override
  String provideSvg(Uint8List? message) =>
      sanitizer.sanitize(utf8.decode(message!, allowMalformed: true));
}
