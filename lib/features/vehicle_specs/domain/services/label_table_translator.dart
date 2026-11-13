/// Traduce un texto con una tabla; sin entrada lo devuelve tal cual.
class LabelTableTranslator {
  const LabelTableTranslator({required this.table, this.onUntranslated});

  /// Clave: valor original; valor: traducción.
  final Map<String, String> table;

  /// Se llama con el texto original cuando no tiene traducción.
  final void Function(String original)? onUntranslated;

  /// Nulo si el texto es nulo o vacío.
  String? labelFor(String? original) {
    if (original == null || original.trim().isEmpty) return null;
    final label = table[original];
    if (label != null) return label;
    onUntranslated?.call(original);
    return original;
  }
}
