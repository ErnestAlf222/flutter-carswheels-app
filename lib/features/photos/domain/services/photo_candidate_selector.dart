import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/photo_candidate_entity.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/photo_entity.dart';

// Año de cuatro dígitos al inicio, sin dígitos pegados detrás.
final RegExp _leadingYearPattern = RegExp(
  '^(\\d{${PhotosConfig.yearDigitCount}})(?!\\d)',
);

/// Elige la mejor foto de una lista de candidatas.
class PhotoCandidateSelector {
  const PhotoCandidateSelector();

  /// Modelo sin siglas de tracción ni puertas y sin espacios sobrantes.
  String cleanModelName(String modelName) {
    final stripTokens = PhotosConfig.photoModelStripTokens
        .map((token) => token.toLowerCase())
        .toSet();
    return modelName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .where((word) => !stripTokens.contains(word.toLowerCase()))
        .join(PhotosConfig.searchTermSeparator);
  }

  /// Foto elegida, o null si ninguna candidata es válida.
  PhotoEntity? select(
    List<PhotoCandidateEntity> candidates,
    String brand,
    String modelName,
    int year,
  ) {
    final brandKey = TextNormalizer.normalize(brand);
    final modelKey = _modelKey(modelName);
    final valid = candidates
        .where((candidate) => _isValid(candidate, brandKey, modelKey))
        .toList();
    final sameYear = valid.where((c) => _matchesYear(_titleOf(c), year));
    final fromYear = _bestRanked(sameYear);
    if (fromYear != null) return _toPhoto(fromYear, isReference: false);
    final others = valid.where((c) => !_matchesYear(_titleOf(c), year));
    final fallback = _bestReference(others, year);
    if (fallback != null) return _toPhoto(fallback, isReference: true);
    return null;
  }

  // Año de cuatro dígitos al inicio del título, o null si no lo trae.
  int? _leadingYear(String title) {
    final match = _leadingYearPattern.firstMatch(title);
    return match == null ? null : int.parse(match.group(1)!);
  }

  // Con año cercano primero (menor diferencia); sin año después; lejanos fuera.
  PhotoCandidateEntity? _bestReference(
    Iterable<PhotoCandidateEntity> candidates,
    int year,
  ) {
    final dated = <PhotoCandidateEntity, int>{};
    final undated = <PhotoCandidateEntity>[];
    for (final candidate in candidates) {
      final leadingYear = _leadingYear(_titleOf(candidate));
      if (leadingYear == null) {
        undated.add(candidate);
        continue;
      }
      final difference = (leadingYear - year).abs();
      if (difference <= PhotosConfig.maxReferenceYearDifference) {
        dated[candidate] = difference;
      }
    }
    if (dated.isEmpty) return _bestRanked(undated);
    return dated.keys.reduce((a, b) {
      final byDifference = dated[b]!.compareTo(dated[a]!);
      if (byDifference != 0) return byDifference < 0 ? b : a;
      return b.rank < a.rank ? b : a;
    });
  }

  // Primera palabra del modelo limpio, normalizada.
  String _modelKey(String modelName) {
    final words = cleanModelName(modelName)
        .split(PhotosConfig.searchTermSeparator);
    return TextNormalizer.normalize(words.first);
  }

  // Título sin el prefijo de archivo.
  String _titleOf(PhotoCandidateEntity candidate) =>
      candidate.title.replaceFirst(PhotosConfig.filePrefix, '');

  bool _isValid(
    PhotoCandidateEntity candidate,
    String brandKey,
    String modelKey,
  ) {
    final title = _titleOf(candidate);
    final normalized = TextNormalizer.normalize(title);
    final lowerTitle = title.toLowerCase();
    final isExcluded = PhotosConfig.excludedTitleWords.any(
      (word) => lowerTitle.contains(word.toLowerCase()),
    );
    return candidate.licenseName.isNotEmpty &&
        !isExcluded &&
        normalized.contains(brandKey) &&
        normalized.contains(modelKey);
  }

  // Empieza con el año y un no dígito, o lo trae entre paréntesis.
  bool _matchesYear(String title, int year) {
    final yearText = '$year';
    if (title.startsWith(yearText)) {
      final rest = title.substring(yearText.length);
      if (rest.isEmpty || !RegExp(r'^\d').hasMatch(rest)) return true;
    }
    return title.contains(
      '${PhotosConfig.yearOpeningDelimiter}$yearText'
      '${PhotosConfig.yearClosingDelimiter}',
    );
  }

  // Candidata de menor rank, o null si no hay ninguna.
  PhotoCandidateEntity? _bestRanked(Iterable<PhotoCandidateEntity> candidates) {
    if (candidates.isEmpty) return null;
    return candidates.reduce((a, b) => b.rank < a.rank ? b : a);
  }

  PhotoEntity _toPhoto(
    PhotoCandidateEntity candidate, {
    required bool isReference,
  }) {
    return PhotoEntity(
      thumbnailUrl: candidate.thumbnailUrl,
      authorName: candidate.authorName,
      licenseName: candidate.licenseName,
      sourceUrl: candidate.sourceUrl,
      isReference: isReference,
    );
  }
}
