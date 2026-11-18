import 'package:cars_wheels_app/core/core.dart';

/// Traduce una grafía de CONUEE a su etiqueta canónica mediante una tabla.
class MxTableLabeler {
  const MxTableLabeler({
    required this.labels,
    this.noData = ConueeConfig.noDataValues,
    this.onUnknown,
  });

  /// Grafía normalizada con TextNormalizer → etiqueta.
  final Map<String, String> labels;

  /// Grafías normalizadas que significan "sin dato".
  final List<String> noData;

  /// Avisa de un valor que no está en la tabla.
  final void Function(String original)? onUnknown;

  /// Etiqueta, nulo si es "sin dato" o el valor tal cual si no se conoce.
  String? label(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    final key = TextNormalizer.normalize(trimmed);
    if (noData.contains(key)) return null;
    final known = labels[key];
    if (known != null) return known;
    onUnknown?.call(trimmed);
    return trimmed;
  }
}
