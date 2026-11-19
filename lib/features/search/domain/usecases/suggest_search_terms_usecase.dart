import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_scope_entity.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_index_store.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_tokenizer.dart';

/// Palabra del vocabulario con su distancia de edición a la palabra buscada.
class SuggestionCandidate {
  const SuggestionCandidate(this.token, this.distance);

  final String token;
  final int distance;
}

/// Sugiere correcciones ("¿Quisiste decir?") cuando la consulta no encuentra nada.
///
/// Compara la primera palabra sin coincidencia con el vocabulario del índice por
/// distancia de edición acotada y solo ofrece las que sí devuelven resultados.
class SuggestSearchTermsUseCase {
  const SuggestSearchTermsUseCase({
    required this.store,
    required this.sortStrategy,
  });

  final SearchIndexStore store;
  final SortStrategy<SuggestionCandidate> sortStrategy;

  /// Hasta [SearchConfig.maxSuggestions] textos corregidos, normalizados.
  List<String> call(SearchScopeEntity scope, String query) {
    final record = store.recordOf(scope.key);
    if (record == null) return const [];
    final index = record.index;
    final tokens = SearchTokenizer.queryTokens(query);
    final failing = tokens.indexWhere((token) => index.match([token]).isEmpty);
    if (failing < 0) return const [];
    final token = tokens[failing];
    if (token.length < SearchConfig.suggestionMinTokenLength) return const [];
    final maxDistance = maxDistanceFor(token.length);
    final candidates = <SuggestionCandidate>[];
    for (final word in index.vocabulary) {
      final distance = _distanceTo(token, word, maxDistance);
      if (distance != null) candidates.add(SuggestionCandidate(word, distance));
    }
    final sorted = sortStrategy.sort(candidates, (a, b) {
      final byDistance = a.distance.compareTo(b.distance);
      return byDistance != 0 ? byDistance : a.token.compareTo(b.token);
    });
    // Solo vale una corrección que realmente encuentre algo.
    final valid = [
      for (final candidate in sorted)
        if (index.match([...tokens]..[failing] = candidate.token).isNotEmpty)
          candidate,
    ];
    if (valid.isEmpty) return const [];
    // Solo se ofrecen las más cercanas: una más lejana que la mejor es ruido.
    final best = valid.first.distance;
    return [
      for (final candidate in valid.where((c) => c.distance == best))
        ([...tokens]..[failing] = candidate.token).join(' '),
    ].take(SearchConfig.maxSuggestions).toList();
  }

  /// Distancia máxima de edición según el largo de la palabra buscada.
  static int maxDistanceFor(int length) =>
      length <= SearchConfig.suggestionShortTokenMaxLength
      ? SearchConfig.suggestionShortMaxDistance
      : SearchConfig.suggestionLongMaxDistance;

  // Distancia a la palabra entera o a su inicio del mismo largo (consulta a medias).
  int? _distanceTo(String token, String word, int maxDistance) {
    final whole = BoundedEditDistance.between(token, word, maxDistance);
    if (word.length <= token.length) return whole;
    final prefix = BoundedEditDistance.between(
      token,
      word.substring(0, token.length),
      maxDistance,
    );
    if (whole == null) return prefix;
    return prefix == null || whole <= prefix ? whole : prefix;
  }
}
