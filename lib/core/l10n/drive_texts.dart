/// Traducciones de la tracción (campo drive) de FuelEconomy.
class DriveTexts {
  const DriveTexts._();

  // Sale del análisis de vehicles.csv del 2026-11-13; un valor ausente se muestra en inglés.
  // Clave: el valor original de drive; el valor vacío no lleva entrada.
  static const Map<String, String> labels = {
    'Front-Wheel Drive': 'Tracción delantera',
    'Rear-Wheel Drive': 'Tracción trasera',
    'All-Wheel Drive': 'Tracción integral',
    '4-Wheel or All-Wheel Drive': '4x4 o integral',
    '4-Wheel Drive': '4x4',
    'Part-time 4-Wheel Drive': '4x4 parcial',
    '2-Wheel Drive': 'Tracción en 2 ruedas',
  };
}
