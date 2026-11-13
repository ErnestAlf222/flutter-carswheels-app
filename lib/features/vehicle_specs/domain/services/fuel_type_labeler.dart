import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/services/label_table_translator.dart';

/// Traduce el tipo de combustible de FuelEconomy al español.
class FuelTypeLabeler extends LabelTableTranslator {
  const FuelTypeLabeler({super.onUntranslated})
    : super(table: FuelTypeTexts.labels);
}
