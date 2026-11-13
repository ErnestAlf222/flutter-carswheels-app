import 'package:cars_wheels_app/core/core.dart';

/// Traduce la clase de FuelEconomy al español, sin el sufijo de tracción.
class VehicleClassTranslator {
  const VehicleClassTranslator({this.onUntranslated});

  /// Se llama con la clase limpia cuando no tiene traducción.
  final void Function(String originalClass)? onUntranslated;

  static final RegExp _driveSuffix = RegExp(
    VehicleSpecsConfig.driveSuffixPattern,
    caseSensitive: false,
  );

  /// Nulo si no hay clase; sin traducción devuelve el texto sin sufijo.
  String? labelFor(String? originalClass) {
    if (originalClass == null || originalClass.trim().isEmpty) return null;
    final cleaned = originalClass.replaceFirst(_driveSuffix, '').trim();
    if (cleaned.isEmpty) return null;
    final label = VehicleClassTexts.labels[cleaned];
    if (label != null) return label;
    onUntranslated?.call(cleaned);
    return cleaned;
  }
}
