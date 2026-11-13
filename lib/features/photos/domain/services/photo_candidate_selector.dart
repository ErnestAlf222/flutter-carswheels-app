import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/photo_candidate_entity.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/photo_entity.dart';

final RegExp _titleTokenPattern = RegExp(
  PhotosConfig.titleTokenPattern,
  unicode: true,
);
final RegExp _leadingYearPattern = RegExp(PhotosConfig.leadingYearPattern);
final RegExp _parenthesizedYearPattern = RegExp(
  PhotosConfig.parenthesizedYearPattern,
);
final RegExp _suffixLettersPattern = RegExp(
  PhotosConfig.modelKeySuffixLettersPattern,
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
    final sameYear = valid.where((c) => _titleYears(c).contains(year));
    final fromYear = _bestRanked(sameYear);
    if (fromYear != null) return _toPhoto(fromYear, isReference: false);
    final others = valid.where((c) => !_titleYears(c).contains(year));
    final fallback = _bestReference(others, year);
    if (fallback != null) return _toPhoto(fallback, isReference: true);
    return null;
  }

  // Años reconocidos del título: el inicial con espacio y los de paréntesis.
  List<int> _titleYears(PhotoCandidateEntity candidate) {
    final title = _titleOf(candidate);
    final years = <int>[];
    final leading = _leadingYearPattern.firstMatch(title);
    if (leading != null) years.add(int.parse(leading.group(1)!));
    for (final match in _parenthesizedYearPattern.allMatches(title)) {
      years.add(int.parse(match.group(1)!));
    }
    return years;
  }

  // Con año cercano primero (menor diferencia); sin año después; lejanos fuera.
  PhotoCandidateEntity? _bestReference(
    Iterable<PhotoCandidateEntity> candidates,
    int year,
  ) {
    final dated = <PhotoCandidateEntity, int>{};
    final undated = <PhotoCandidateEntity>[];
    for (final candidate in candidates) {
      final years = _titleYears(candidate);
      if (years.isEmpty) {
        undated.add(candidate);
        continue;
      }
      final difference = years
          .map((titleYear) => (titleYear - year).abs())
          .reduce((a, b) => a < b ? a : b);
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
    final lowerTitle = title.toLowerCase();
    final isExcluded = PhotosConfig.excludedTitleWords.any(
      (word) => lowerTitle.contains(word.toLowerCase()),
    );
    return candidate.licenseName.isNotEmpty &&
        !isExcluded &&
        _hasModelAfterBrand(title, brandKey, modelKey);
  }

  // La marca aparece y, tras alguna aparición, el modelo está cerca.
  bool _hasModelAfterBrand(String title, String brandKey, String modelKey) {
    final words = title
        .split(_titleTokenPattern)
        .where((word) => word.isNotEmpty)
        .toList();
    final normalized = words.map(TextNormalizer.normalize).toList();
    for (final start in Iterable<int>.generate(words.length)) {
      final brandEnd = _brandEnd(normalized, start, brandKey);
      if (brandEnd == null) continue;
      final lastStart = brandEnd + PhotosConfig.brandModelMaxWordGap;
      final gapSize = lastStart - brandEnd + 1;
      for (final offset in Iterable<int>.generate(gapSize)) {
        if (_modelStartsAt(normalized, brandEnd + offset, modelKey)) {
          return true;
        }
      }
    }
    return false;
  }

  // Fin (exclusivo) de la marca que empieza en start, o null si no coincide.
  int? _brandEnd(List<String> normalized, int start, String brandKey) {
    final remaining = normalized.length - start;
    for (final span in Iterable<int>.generate(remaining, (i) => i + 1)) {
      final joined = normalized.skip(start).take(span).join();
      if (joined.length < brandKey.length) continue;
      return joined == brandKey ? start + span : null;
    }
    return null;
  }

  // Las palabras desde index forman la clave, con letras sobrantes al final.
  bool _modelStartsAt(List<String> normalized, int index, String modelKey) {
    final remaining = normalized.length - index;
    final maxSpan = remaining < PhotosConfig.modelKeyMaxTokenSpan
        ? remaining
        : PhotosConfig.modelKeyMaxTokenSpan;
    for (final span in Iterable<int>.generate(maxSpan, (i) => i + 1)) {
      final text = normalized.skip(index).take(span).join();
      if (text == modelKey) return true;
      if (text.startsWith(modelKey) &&
          _suffixLettersPattern.hasMatch(text.substring(modelKey.length))) {
        return true;
      }
    }
    return false;
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
