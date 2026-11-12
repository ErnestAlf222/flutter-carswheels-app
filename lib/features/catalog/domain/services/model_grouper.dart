import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/entities/model_entity.dart';
import 'package:cars_wheels_app/features/catalog/domain/entities/model_group_entity.dart';

// Nombre base de un modelo y si pertenece a una familia protegida.
typedef _BaseName = ({List<String> words, bool isProtected});

/// Agrupa las variantes de FuelEconomy en una fila por modelo.
class ModelGrouper {
  const ModelGrouper({required this.sortStrategy});

  final SortStrategy<ModelGroupEntity> sortStrategy;

  /// Agrupa los modelos de una marca y ordena los grupos por nombre.
  List<ModelGroupEntity> group(String brand, List<ModelEntity> models) {
    final brandKey = TextNormalizer.normalize(brand);
    final unique = models.toSet().toList();
    final bases = [for (final model in unique) _baseName(model.name, brandKey)];
    final candidates = <String, List<String>>{
      for (final base in bases) _key(base.words): base.words,
    };
    final membersByRoot = <String, List<ModelEntity>>{};
    for (int index = 0; index < unique.length; index++) {
      final base = bases[index];
      final root = base.isProtected
          ? _key(base.words)
          : _shortestPrefixKey(base.words, candidates);
      membersByRoot.putIfAbsent(root, () => []).add(unique[index]);
    }
    final groups = [
      for (final entry in membersByRoot.entries)
        ModelGroupEntity(
          name: _displayName(candidates[entry.key]!, brandKey),
          variants: entry.value,
        ),
    ];
    return sortStrategy.sort(
      groups,
      (a, b) =>
          TextNormalizer.normalize(a.name)
              .compareTo(TextNormalizer.normalize(b.name)),
    );
  }

  // Nombre del grupo: el de la tabla de la marca si existe, o las palabras unidas.
  static String _displayName(List<String> words, String brandKey) {
    final joined = words.join(' ');
    final names = ModelGroupingConfig.groupDisplayNames[brandKey];
    return names?[TextNormalizer.normalize(joined)] ?? joined;
  }

  // Llave de comparación: cada palabra normalizada, separadas por un espacio.
  static String _key(List<String> words) =>
      words.map(TextNormalizer.normalize).join(' ');

  static List<String> _split(String text) => text
      .split(RegExp(ModelGroupingConfig.wordSeparatorPattern))
      .where((word) => word.isNotEmpty)
      .toList();

  // Pasos 1 y 2: quita paréntesis y sufijos de variante, y aplica familias protegidas.
  static _BaseName _baseName(String name, String brandKey) {
    final cleaned = _split(
      name.replaceAll(RegExp(ModelGroupingConfig.parenthesisPattern), ''),
    );
    final spaced = cleaned.isEmpty ? _split(name) : cleaned;
    if (spaced.isEmpty) return (words: [name], isProtected: false);
    final words = _removeInline(spaced);
    final tokens = <List<String>>[
      for (final token in [
        ...ModelGroupingConfig.variantTrailingTokens,
        ...?ModelGroupingConfig.brandVariantTrailingTokens[brandKey],
      ])
        _split(token.toLowerCase()),
    ]..sort((a, b) => b.length.compareTo(a.length));
    final patterns = [
      for (final pattern
          in ModelGroupingConfig.brandVariantTrailingPatterns[brandKey] ??
              const <String>[])
        RegExp(pattern, caseSensitive: false),
    ];
    final stripped = _stripTrailing(words, tokens, patterns, words.first);
    final absorbing = _absorbingBase(stripped, brandKey);
    if (absorbing != null) return (words: absorbing, isProtected: true);
    final family = _protectedFamily(stripped, brandKey);
    return family == null
        ? (words: stripped, isProtected: false)
        : (words: family, isProtected: true);
  }

  // Quita sufijos del final hasta que no cambie nada; nunca deja el nombre vacío.
  static List<String> _stripTrailing(
    List<String> words,
    List<List<String>> tokens,
    List<RegExp> patterns,
    String firstWord,
  ) {
    if (words.length > 1 && patterns.any((p) => p.hasMatch(words.last))) {
      return _stripTrailing(
        words.sublist(0, words.length - 1),
        tokens,
        patterns,
        firstWord,
      );
    }
    for (final token in tokens) {
      if (!_endsWith(words, token)) continue;
      if (words.length == token.length) return [firstWord];
      return _stripTrailing(
        words.sublist(0, words.length - token.length),
        tokens,
        patterns,
        firstWord,
      );
    }
    return words;
  }

  // Quita las palabras de variantInlineTokens de cualquier posición; nunca deja vacío.
  static List<String> _removeInline(List<String> words) {
    final inline = ModelGroupingConfig.variantInlineTokens
        .map(TextNormalizer.normalize)
        .toSet();
    final kept = [
      for (final word in words)
        if (!inline.contains(TextNormalizer.normalize(word))) word,
    ];
    return kept.isEmpty ? words : kept;
  }

  // La base absorbente más larga con la que empieza el nombre, si hay alguna.
  static List<String>? _absorbingBase(List<String> words, String brandKey) {
    final bases = ModelGroupingConfig.absorbingModelBases[brandKey];
    if (bases == null) return null;
    final wordsKey = _key(words);
    final matches = [
      for (final base in bases.map(_split))
        if (_isWordPrefix(_key(base), wordsKey)) base,
    ]..sort((a, b) => b.length.compareTo(a.length));
    return matches.isEmpty ? null : matches.first;
  }

  static bool _endsWith(List<String> words, List<String> token) {
    if (words.length < token.length) return false;
    final offset = words.length - token.length;
    for (int index = 0; index < token.length; index++) {
      if (words[offset + index].toLowerCase() != token[index]) return false;
    }
    return true;
  }

  // La familia protegida más larga con la que empieza el nombre, si hay alguna.
  static List<String>? _protectedFamily(List<String> words, String brandKey) {
    final families = ModelGroupingConfig.protectedModelFamilies[brandKey];
    if (families == null) return null;
    final wordsKey = _key(words);
    final matches = [
      for (final family in families.map(_split))
        if (_isWordPrefix(_key(family), wordsKey)) family,
    ]..sort((a, b) => b.length.compareTo(a.length));
    return matches.isEmpty ? null : matches.first;
  }

  // Paso 3: llave del nombre base más corto que es prefijo por palabras completas.
  static String _shortestPrefixKey(
    List<String> words,
    Map<String, List<String>> candidates,
  ) {
    final wordsKey = _key(words);
    final prefixes = [
      for (final key in candidates.keys)
        if (_isWordPrefix(key, wordsKey)) key,
    ]..sort((a, b) => a.split(' ').length.compareTo(b.split(' ').length));
    return prefixes.first;
  }

  // Verdadero si prefix es igual a key o la abre seguido de una palabra nueva.
  static bool _isWordPrefix(String prefix, String key) =>
      key == prefix || key.startsWith('$prefix ');
}
