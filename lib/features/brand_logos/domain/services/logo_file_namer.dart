import 'package:cars_wheels_app/core/config/logos_config.dart';

/// Nombres de archivo de los logos en disco: marca, versión fijada y regla.
class LogoFileNamer {
  const LogoFileNamer();

  static final RegExp _pinnedVersion = RegExp(
    LogoDiskConfig.pinnedVersionPattern,
  );
  static final RegExp _nonAlphanumeric = RegExp(r'[^a-z0-9]+');

  /// Nombre del logo en [url], o nulo si no se puede guardar.
  ///
  /// El logo del CDN solo se guarda con la versión fijada en la URL (nunca
  /// "latest"); el de Commons lleva un hash de su URL.
  String? svgFileNameFor(String url) {
    if (!url.endsWith(LogosConfig.svgExtension)) return null;
    final slug = _slugOf(_lastSegment(url));
    if (slug.isEmpty) return null;
    final version = _versionTagOf(url);
    return version == null ? null : _join(slug, version);
  }

  /// Nombre del manifiesto de la versión fijada; nulo si la base no está fijada.
  String? manifestFileNameFor(String baseUrl) {
    final version = _versionTagOf(baseUrl);
    if (version == null) return null;
    return _join(
      _slugOf(LogosConfig.manifestFileName),
      version,
      extension: _manifestExtension,
    );
  }

  /// Marca (parte inicial del nombre) de un archivo; sirve para podar versiones viejas.
  String brandPrefixOf(String fileName) =>
      fileName.split(LogoDiskConfig.versionSeparator).first;

  static const String _manifestExtension = '.json';

  String _join(String slug, String version, {String? extension}) =>
      [
        slug,
        version,
        LogoDiskConfig.formatVersion,
      ].join(LogoDiskConfig.versionSeparator) +
      (extension ?? LogoDiskConfig.fileExtension);

  String? _versionTagOf(String url) {
    final pinned = _pinnedVersion.firstMatch(url)?.group(1);
    if (pinned != null) {
      return pinned.substring(0, LogoDiskConfig.versionPrefixLength);
    }
    // Una URL del CDN sin hash fijado ("latest", rama) no se guarda.
    if (url.startsWith(LogosConfig.logosBaseUrlHost)) return null;
    return '${LogoDiskConfig.commonsVersionTag}-${_hash(url)}';
  }

  String _lastSegment(String url) =>
      Uri.tryParse(url)?.pathSegments.lastOrNull ?? '';

  String _slugOf(String name) => name
      .toLowerCase()
      .replaceAll(LogosConfig.svgExtension, '')
      .replaceAll(_nonAlphanumeric, '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  // Hash estable (FNV-1a de 32 bits) para distinguir URLs sin versión.
  String _hash(String text) {
    int value = 0x811c9dc5;
    for (final unit in text.codeUnits) {
      value = ((value ^ unit) * 0x01000193) & 0xffffffff;
    }
    return value.toRadixString(16).padLeft(8, '0');
  }
}
