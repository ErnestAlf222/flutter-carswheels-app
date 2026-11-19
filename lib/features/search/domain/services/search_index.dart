import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_entry_entity.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_tokenizer.dart';

/// Token con las filas del índice que lo contienen.
class SearchPosting {
  const SearchPosting({required this.token, required this.entryIds});

  final String token;
  final List<int> entryIds;
}

/// Índice invertido en memoria: tokens ordenados que apuntan a filas.
class SearchIndex {
  const SearchIndex._(this.entries, this._postings);

  /// Índice sin filas.
  static const SearchIndex empty = SearchIndex._([], []);

  /// Construye el índice de "marca + nombre del grupo" de cada fila.
  factory SearchIndex.build(
    List<SearchEntryEntity> entries,
    SortStrategy<SearchPosting> sortStrategy,
  ) {
    final idsByToken = <String, List<int>>{};
    for (final (id, entry) in entries.indexed) {
      final text = '${entry.brand} ${entry.groupName ?? ''}';
      for (final token in SearchTokenizer.indexTokens(text)) {
        idsByToken.putIfAbsent(token, () => []).add(id);
      }
    }
    final postings = sortStrategy.sort([
      for (final item in idsByToken.entries)
        SearchPosting(token: item.key, entryIds: item.value),
    ], (a, b) => a.token.compareTo(b.token));
    return SearchIndex._(List.unmodifiable(entries), postings);
  }

  final List<SearchEntryEntity> entries;
  final List<SearchPosting> _postings;

  /// Tokens distintos del índice, en orden alfabético.
  List<String> get vocabulary => [
    for (final posting in _postings) posting.token,
  ];

  /// Filas donde todos los tokens de la consulta son prefijo de algún token.
  List<SearchEntryEntity> match(List<String> queryTokens) {
    if (queryTokens.isEmpty) return const [];
    Set<int>? common;
    for (final token in queryTokens) {
      final ids = _idsWithPrefix(token);
      common = common == null ? ids : common.intersection(ids);
      if (common.isEmpty) return const [];
    }
    final sorted = common!.toList()..sort();
    return [for (final id in sorted) entries[id]];
  }

  Set<int> _idsWithPrefix(String prefix) {
    final matches = BinarySearch.withPrefix(
      _postings,
      prefix,
      (posting) => posting.token,
    );
    return {for (final posting in matches) ...posting.entryIds};
  }
}
