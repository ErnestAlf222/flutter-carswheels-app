import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/services/label_table_translator.dart';

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
    return LabelTableTranslator(
      table: VehicleClassTexts.labels,
      onUntranslated: onUntranslated,
    ).labelFor(cleaned);
  }
}
