import 'package:cars_wheels_app/core/core.dart';

/// Texto con su copia en minúsculas y sin acentos, del mismo largo.
class _FoldedText {
  const _FoldedText(this.original, this.folded);

  factory _FoldedText.of(String text) {
    final folded = text.split('').map((char) {
      final lower = char.toLowerCase();
      return lower.length == 1
          ? (TextConfig.accentReplacements[lower] ?? lower)
          : char;
    }).join();
    return _FoldedText(text, folded);
  }

  final String original;
  final String folded;

  /// Cambia por espacios lo que encaje con el patrón en ambas copias.
  _FoldedText remove(RegExp pattern) {
    final blank = List<bool>.filled(folded.length, false);
    for (final match in pattern.allMatches(folded)) {
      for (int index = match.start; index < match.end; index++) {
        blank[index] = true;
      }
    }
    if (!blank.contains(true)) return this;
    String mask(String text) => [
      for (int index = 0; index < text.length; index++)
        blank[index] ? ' ' : text[index],
    ].join();
    return _FoldedText(mask(original), mask(folded));
  }
}

/// Deja en el modelo solo su nombre: sin marca, cilindrada, potencia,
/// transmisión, tracción, electrificación ni variantes finales.
class MxModelNameCleaner {
  const MxModelNameCleaner();

  static final RegExp _separator = RegExp(
    MexicoModelConfig.wordSeparatorPattern,
  );
  static final RegExp _parenthesis = RegExp(
    MexicoModelConfig.parenthesisPattern,
  );
  static final RegExp _unclosed = RegExp(
    MexicoModelConfig.unclosedParenthesisPattern,
  );
  static final RegExp _noise = RegExp(MexicoModelConfig.noisePattern);
  static final RegExp _trailingLetter = RegExp(
    MexicoModelConfig.trailingLetterPattern,
  );
  static final List<RegExp> _inline = [
    for (final pattern in MexicoModelConfig.inlineRemovalPatterns)
      RegExp(pattern),
  ];

  /// Modelo original sin el prefijo de la marca, con su escritura original.
  String stripBrandPrefix(String brand, String rawModel) {
    final text = _FoldedText.of(rawModel.trim());
    final stripped = _removeLeading(text, _brandPhrases(brand));
    return _words(stripped.original).isEmpty
        ? rawModel.trim()
        : _words(stripped.original).join(' ');
  }

  /// Nombre limpio; si no queda nada, el modelo sin marca tal como viene.
  String clean(String brand, String rawModel) {
    final brandKey = TextNormalizer.normalize(brand);
    final base = _FoldedText.of(rawModel.trim())
        .remove(_parenthesis)
        .remove(_unclosed)
        .remove(_noise);
    final noBrand = _removeLeading(base, _brandPhrases(brand));
    final noLeading = _removeLeading(noBrand, [
      for (final token
          in MexicoModelConfig.brandLeadingTokens[brandKey] ?? const <String>[])
        token.toLowerCase(),
    ]);
    final cleaned = _inline.fold<_FoldedText>(
      noLeading,
      (text, pattern) => text.remove(pattern),
    );
    final words = _dedupe(_words(cleaned.original));
    final stripped = _stripTrailing(words, _trailingTokens(brandKey));
    final aliased = _applyAlias(stripped, brandKey);
    if (aliased.isNotEmpty) return aliased.join(' ');
    // Sin nada que conservar, el modelo sin la marca tal como viene.
    final fallback = _words(noBrand.original);
    return fallback.isEmpty ? rawModel.trim() : fallback.join(' ');
  }

  // Frases de la marca a quitar: la completa y su primera palabra.
  static List<String> _brandPhrases(String brand) {
    final folded = _FoldedText.of(brand.trim()).folded;
    final first = folded.split(_separator).first;
    return [folded, if (first != folded) first];
  }

  // Quita al principio cada frase que encaje, sin dejar el nombre vacío.
  static _FoldedText _removeLeading(_FoldedText text, List<String> phrases) {
    return phrases.fold<_FoldedText>(text, (current, phrase) {
      final pattern = RegExp('^\\s*${RegExp.escape(phrase)}(?=\\s|\$)');
      final next = current.remove(pattern);
      return _words(next.original).isEmpty ? current : next;
    });
  }

  static List<String> _words(String text) =>
      text.split(_separator).where((word) => word.isNotEmpty).toList();

  static String _fold(String word) => _FoldedText.of(word).folded;

  // Palabras repetidas seguidas: "INTEGRA INTEGRA" → "INTEGRA".
  static List<String> _dedupe(List<String> words) => [
    for (int index = 0; index < words.length; index++)
      if (index == 0 || _fold(words[index]) != _fold(words[index - 1]))
        words[index],
  ];

  // Sufijos de versión, los más largos primero, ya en minúsculas por palabras.
  static List<List<String>> _trailingTokens(String brandKey) {
    final tokens =
        [
          for (final token in [
            ...MexicoModelConfig.variantTrailingTokens,
            ...?MexicoModelConfig.brandVariantTrailingTokens[brandKey],
          ])
            _words(_fold(token)),
        ]..sort((a, b) {
          final byLength = b.length.compareTo(a.length);
          return byLength != 0 ? byLength : a.join(' ').compareTo(b.join(' '));
        });
    return tokens;
  }

  // Quita sufijos y letras sueltas del final; siempre deja al menos una palabra.
  static List<String> _stripTrailing(
    List<String> words,
    List<List<String>> tokens,
  ) {
    if (words.length <= 1) return words;
    final folded = words.map(_fold).toList();
    for (final token in tokens) {
      if (words.length <= token.length) continue;
      final offset = words.length - token.length;
      final matches = [
        for (int index = 0; index < token.length; index++)
          folded[offset + index] == token[index],
      ].every((hit) => hit);
      if (matches) return _stripTrailing(words.sublist(0, offset), tokens);
    }
    if (_trailingLetter.hasMatch(folded.last)) {
      return _stripTrailing(words.sublist(0, words.length - 1), tokens);
    }
    return words;
  }

  // Reescribe un prefijo conocido: "RANGE ROVER VELAR" → "VELAR".
  static List<String> _applyAlias(List<String> words, String brandKey) {
    final aliases = MexicoModelConfig.modelPrefixAliases[brandKey];
    if (aliases == null) return words;
    final folded = words.map(_fold).toList();
    for (final entry in aliases.entries) {
      final prefix = _words(_fold(entry.key));
      if (folded.length < prefix.length) continue;
      final matches = [
        for (int index = 0; index < prefix.length; index++)
          folded[index] == prefix[index],
      ].every((hit) => hit);
      if (matches) return [entry.value, ...words.sublist(prefix.length)];
    }
    return words;
  }
}
