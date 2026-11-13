import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/photo_candidate_entity.dart';

/// Convierte una página de Commons en una foto candidata.
class CommonsCandidateMapper {
  const CommonsCandidateMapper._();

  static final RegExp _tagPattern = RegExp(PhotosConfig.htmlTagPattern);
  static final RegExp _entityPattern = RegExp(
    PhotosConfig.htmlEntities.keys.map(RegExp.escape).join('|'),
  );

  /// Sin orden usa el rank más alto; lanza ParsingFailure si falta otro dato.
  static PhotoCandidateEntity toCandidate(Map<String, dynamic> page) {
    final info = _readInfo(page);
    final metadata = info[PhotosConfig.extMetadataKey];
    return PhotoCandidateEntity(
      title: _readString(page, PhotosConfig.titleKey),
      thumbnailUrl: _readString(info, PhotosConfig.thumbnailUrlKey),
      authorName: cleanHtml(
        _readMetadataValue(metadata, PhotosConfig.artistKey),
      ),
      licenseName: _readMetadataValue(metadata, PhotosConfig.licenseKey),
      sourceUrl: _readString(info, PhotosConfig.descriptionUrlKey),
      rank: _readRank(page),
      aspectRatio: _readAspectRatio(info),
    );
  }

  /// Quita las etiquetas HTML y decodifica las entidades.
  static String cleanHtml(String html) {
    final withoutTags = html.replaceAll(_tagPattern, '');
    return withoutTags
        .replaceAllMapped(
          _entityPattern,
          (match) => PhotosConfig.htmlEntities[match.group(0)] ?? '',
        )
        .trim();
  }

  static Map<String, dynamic> _readInfo(Map<String, dynamic> page) {
    final list = page[PhotosConfig.imageInfoKey];
    if (list is List<dynamic> && list.isNotEmpty) {
      final first = list.first;
      if (first is Map<String, dynamic>) return first;
    }
    throw const ParsingFailure('La página de Commons no tiene imageinfo');
  }

  static String _readString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is String) return value;
    throw ParsingFailure('Falta el texto $key en la respuesta de Commons');
  }

  // Ancho entre alto de la miniatura; nulo si falta alguno o el alto es 0.
  static double? _readAspectRatio(Map<String, dynamic> info) {
    final width = info[PhotosConfig.thumbnailWidthKey];
    final height = info[PhotosConfig.thumbnailHeightKey];
    if (width is! num || height is! num || height <= 0) return null;
    return width / height;
  }

  static int _readRank(Map<String, dynamic> page) {
    final value = page[PhotosConfig.rankKey];
    return value is int ? value : PhotosConfig.missingRank;
  }

  // Valor de un campo de extmetadata; vacío si no existe.
  static String _readMetadataValue(Object? metadata, String key) {
    if (metadata is! Map<String, dynamic>) return '';
    final entry = metadata[key];
    if (entry is! Map<String, dynamic>) return '';
    final value = entry[PhotosConfig.valueKey];
    return value is String ? value : '';
  }
}
