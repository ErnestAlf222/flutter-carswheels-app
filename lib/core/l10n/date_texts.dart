/// Nombres de mes y formato de fechas en español.
class DateTexts {
  const DateTexts._();

  static const List<String> monthNames = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  /// Fecha larga, por ejemplo "5 de marzo de 2023".
  static String longDate(DateTime date) =>
      '${date.day} de ${monthNames[date.month - 1]} de ${date.year}';
}
