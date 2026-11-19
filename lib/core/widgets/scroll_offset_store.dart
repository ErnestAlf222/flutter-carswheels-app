/// Guarda la posición de scroll de cada sección mientras su contexto no cambie.
class ScrollOffsetStore {
  final Map<String, ({String contextKey, double offset})> _entries = {};

  /// Posición guardada; 0 si no hay o si el contexto (mercado, año) es otro.
  double offsetFor(String section, String contextKey) {
    final entry = _entries[section];
    return entry != null && entry.contextKey == contextKey ? entry.offset : 0.0;
  }

  void save(String section, String contextKey, double offset) {
    _entries[section] = (contextKey: contextKey, offset: offset);
  }

  void clear(String section) => _entries.remove(section);
}
