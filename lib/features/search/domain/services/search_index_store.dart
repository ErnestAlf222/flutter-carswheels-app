import 'package:cars_wheels_app/features/search/domain/entities/search_index_status_entity.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_index.dart';

/// Índice de un mercado y año con su estado.
class SearchIndexRecord {
  const SearchIndexRecord({
    required this.index,
    required this.status,
    this.emptyStreaks = const {},
  });

  final SearchIndex index;
  final SearchIndexStatusEntity status;

  /// Vacíos seguidos por marca sin confirmar; un error o un éxito reinicia la cuenta.
  final Map<String, int> emptyStreaks;

  /// Un índice listo exige todas las marcas indexadas y sin fallidas; uno parcial
  /// exige las fallidas. Cualquier otra combinación es una caché inválida.
  bool get isConsistent {
    final brandRows = index.entries.where((entry) => entry.groupName == null);
    if (brandRows.length != status.totalBrands) return false;
    return switch (status.phase) {
      SearchIndexPhase.ready =>
        status.failedBrands.isEmpty &&
            status.completedBrands == status.totalBrands,
      SearchIndexPhase.partial => status.failedBrands.isNotEmpty,
      SearchIndexPhase.building => true,
    };
  }
}

/// Índices de la sesión por clave mercado|año; viven solo en memoria.
class SearchIndexStore {
  final Map<String, SearchIndexRecord> _records = {};

  SearchIndexRecord? recordOf(String key) => _records[key];

  void save(String key, SearchIndexRecord record) => _records[key] = record;

  void remove(String key) => _records.remove(key);
}
