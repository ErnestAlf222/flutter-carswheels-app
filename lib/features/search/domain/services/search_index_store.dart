import 'package:cars_wheels_app/features/search/domain/entities/search_index_status_entity.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_index.dart';

/// Índice de un mercado y año con su estado.
class SearchIndexRecord {
  const SearchIndexRecord({required this.index, required this.status});

  final SearchIndex index;
  final SearchIndexStatusEntity status;
}

/// Índices de la sesión por clave mercado|año; viven solo en memoria.
class SearchIndexStore {
  final Map<String, SearchIndexRecord> _records = {};

  SearchIndexRecord? recordOf(String key) => _records[key];

  void save(String key, SearchIndexRecord record) => _records[key] = record;

  void remove(String key) => _records.remove(key);
}
