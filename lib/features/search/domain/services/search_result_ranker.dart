import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_entry_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_result_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_scope_entity.dart';

/// Fila con su nivel de coincidencia y su clave alfabética.
class RankedSearchEntry {
  const RankedSearchEntry({
    required this.entry,
    required this.level,
    required this.sortKey,
  });

  final SearchEntryEntity entry;
  final int level;
  final String sortKey;
}

/// Ordena las coincidencias: grupo exacto, prefijo de grupo y marca; dentro de
/// cada nivel, alfabético. Corta al máximo de resultados (nulo: sin corte).
class SearchResultRanker {
  const SearchResultRanker({required this.sortStrategy});

  final SortStrategy<RankedSearchEntry> sortStrategy;

  List<SearchResultEntity> rank({
    required List<SearchEntryEntity> matches,
    required String query,
    required SearchScopeEntity scope,
    int? limit = SearchConfig.maxResults,
  }) {
    final normalizedQuery = TextNormalizer.normalize(query);
    final ranked = sortStrategy.sort([
      for (final entry in matches) _rankOf(entry, normalizedQuery),
    ], _compare);
    return [
      for (final item in limit == null ? ranked : ranked.take(limit))
        SearchResultEntity(
          brand: item.entry.brand,
          groupName: item.entry.groupName,
          year: scope.year,
          marketCode: scope.marketCode,
        ),
    ];
  }

  RankedSearchEntry _rankOf(SearchEntryEntity entry, String query) {
    final group = entry.groupName;
    final groupKey = group == null ? '' : TextNormalizer.normalize(group);
    final level = group == null
        ? SearchConfig.brandLevel
        : groupKey == query
        ? SearchConfig.exactGroupLevel
        : groupKey.startsWith(query)
        ? SearchConfig.prefixGroupLevel
        : SearchConfig.brandLevel;
    // Marca + grupo + textos originales: orden total y estable.
    final sortKey = [
      TextNormalizer.normalize(entry.brand),
      groupKey,
      entry.brand,
      group ?? '',
    ].join(SearchConfig.sortKeySeparator);
    return RankedSearchEntry(entry: entry, level: level, sortKey: sortKey);
  }

  int _compare(RankedSearchEntry a, RankedSearchEntry b) {
    final byLevel = a.level.compareTo(b.level);
    return byLevel != 0 ? byLevel : a.sortKey.compareTo(b.sortKey);
  }
}
