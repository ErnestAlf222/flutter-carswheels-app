import 'package:cars_wheels_app/core/core.dart';

// Palabras separadas por espacios en blanco.
final RegExp _whitespace = RegExp(r'\s+');

/// Parte el texto en tokens normalizados para indexar y para consultar.
class SearchTokenizer {
  const SearchTokenizer._();

  /// Tokens de la consulta: uno por palabra; "F-150" queda como "f150".
  static List<String> queryTokens(String text) {
    final tokens = <String>[];
    for (final word in text.trim().split(_whitespace)) {
      final token = TextNormalizer.normalize(word);
      if (token.isNotEmpty && !tokens.contains(token)) tokens.add(token);
    }
    return tokens;
  }

  /// Tokens de un texto indexado: cada palabra entera y las partes de las que
  /// llevan guion, para que "150" encuentre "F-150".
  static Set<String> indexTokens(String text) {
    final tokens = <String>{};
    for (final word in text.trim().split(_whitespace)) {
      final whole = TextNormalizer.normalize(word);
      if (whole.isEmpty) continue;
      tokens.add(whole);
      if (!word.contains(SearchConfig.tokenHyphen)) continue;
      for (final part in word.split(SearchConfig.tokenHyphen)) {
        final token = TextNormalizer.normalize(part);
        if (token.isNotEmpty) tokens.add(token);
      }
    }
    return tokens;
  }
}
