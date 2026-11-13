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
    final photos = selectMany(candidates, brand, modelName, year, 1);
    return photos.isEmpty ? null : photos.first;
  }

  /// Hasta limit fotos válidas: las del año y luego las de referencia.
  List<PhotoEntity> selectMany(
    List<PhotoCandidateEntity> candidates,
    String brand,
    String modelName,
    int year,
    int limit,
  ) {
    final brandKey = TextNormalizer.normalize(brand);
    final modelKey = _modelKey(modelName);
    final valid = candidates
        .where((candidate) => _isValid(candidate, brandKey, modelKey))
        .toList();
    final sameYear = valid.where((c) => _titleYears(c).contains(year));
    final others = valid.where((c) => !_titleYears(c).contains(year));
    final ordered = <PhotoEntity>[
      ..._byRank(sameYear).map((c) => _toPhoto(c, isReference: false)),
      ..._referenceOrder(
        others,
        year,
      ).map((c) => _toPhoto(c, isReference: true)),
    ];
    final seenSources = <String>{};
    return ordered
        .where((photo) => seenSources.add(photo.sourceUrl))
        .take(limit < 0 ? 0 : limit)
        .toList();
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

  // Con año cercano primero (menor diferencia, luego rank); sin año al final.
  List<PhotoCandidateEntity> _referenceOrder(
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
    final byDifference = _stableSorted(
      dated.keys,
      (a, b) => dated[a]!.compareTo(dated[b]!),
    );
    return [...byDifference, ..._byRank(undated)];
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

  // Candidatas de menor a mayor rank; el orden original rompe los empates.
  List<PhotoCandidateEntity> _byRank(Iterable<PhotoCandidateEntity> items) =>
      _stableSorted(items, (a, b) => 0);

  // Orden por criterio, luego rank y luego posición original (estable).
  List<PhotoCandidateEntity> _stableSorted(
    Iterable<PhotoCandidateEntity> items,
    int Function(PhotoCandidateEntity a, PhotoCandidateEntity b) criterion,
  ) {
    final indexed = items.toList().asMap().entries.toList()
      ..sort((a, b) {
        final byCriterion = criterion(a.value, b.value);
        if (byCriterion != 0) return byCriterion;
        final byRank = a.value.rank.compareTo(b.value.rank);
        return byRank != 0 ? byRank : a.key.compareTo(b.key);
      });
    return [for (final entry in indexed) entry.value];
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
