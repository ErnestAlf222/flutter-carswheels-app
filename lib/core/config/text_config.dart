/// Configuración del tratamiento de texto.
class TextConfig {
  const TextConfig._();

  // Formato de números para mostrar; el patrón agrupa de tres en tres cifras.
  static const String thousandsSeparator = ',';
  static const String thousandsBoundaryPattern = r'\B(?=(\d{3})+(?!\d))';
  static const int displacementFractionDigits = 1;
  static const int kmPerLiterFractionDigits = 1;

  // La normalización trabaja sobre texto en minúsculas.
  static const Map<String, String> accentReplacements = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ñ': 'n',
    'ç': 'c',
  };
}
