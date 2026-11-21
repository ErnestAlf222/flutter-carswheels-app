import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_entry_entity.dart';

/// Elige la siguiente página del feed: orden aleatorio determinista por semilla.
///
/// Cada modelo tiene un puesto que sale de su identidad y de la semilla, no de
/// su posición en el índice: aunque el índice crezca, lo ya mostrado no cambia
/// de lugar y lo nuevo se reparte entre lo que falta, sin repetir.
class SearchFeedPlanner {
  const SearchFeedPlanner();

  /// Identidad de un modelo dentro del alcance: marca y grupo.
  static String keyOf(SearchEntryEntity entry) =>
      '${entry.brand}${SearchConfig.feedKeySeparator}${entry.groupName ?? ''}';

  /// Hasta [pageSize] modelos de [groups] que no estén en [exclude], y cuántos
  /// más quedan después. Las filas de marca sola no cuentan.
  ({List<SearchEntryEntity> page, int remaining}) plan(
    List<SearchEntryEntity> groups, {
    required int seed,
    required Set<String> exclude,
    required int pageSize,
  }) {
    final pool = [
      for (final entry in groups)
        if (entry.groupName != null && !exclude.contains(keyOf(entry))) entry,
    ];
    final ranked =
        [for (final entry in pool) (entry, _rank(seed, keyOf(entry)))]
          ..sort((a, b) {
            final byRank = a.$2.compareTo(b.$2);
            return byRank != 0 ? byRank : keyOf(a.$1).compareTo(keyOf(b.$1));
          });
    final page = [for (final item in ranked.take(pageSize)) item.$1];
    return (page: page, remaining: pool.length - page.length);
  }

  // FNV-1a de 32 bits sobre la semilla y la identidad; igual en cada plataforma.
  static int _rank(int seed, String key) {
    final bytes = [seed & SearchConfig.feedHashMask, ...key.codeUnits];
    return bytes.fold<int>(
      SearchConfig.feedHashOffset,
      (hash, byte) =>
          ((hash ^ byte) * SearchConfig.feedHashPrime) &
          SearchConfig.feedHashMask,
    );
  }
}
