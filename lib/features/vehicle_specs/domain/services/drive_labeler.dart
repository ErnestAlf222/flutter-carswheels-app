import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/services/label_table_translator.dart';

/// Traduce la tracción de FuelEconomy al español.
class DriveLabeler extends LabelTableTranslator {
  const DriveLabeler({super.onUntranslated}) : super(table: DriveTexts.labels);
}
