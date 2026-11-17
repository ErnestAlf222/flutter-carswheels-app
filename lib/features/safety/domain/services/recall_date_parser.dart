import 'package:cars_wheels_app/core/core.dart';

/// Lee la fecha de un recall; nulo si no es dd/MM/yyyy válida.
class RecallDateParser {
  const RecallDateParser();

  DateTime? parse(String? text) {
    if (text == null) return null;
    final match = RegExp(SafetyConfig.recallDatePattern)
        .firstMatch(text.trim());
    if (match == null) return null;
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final date = DateTime.utc(year, month, day);
    // Rechaza fechas que el calendario corrige (31/02).
    final valid = date.year == year && date.month == month && date.day == day;
    return valid ? date : null;
  }
}
