/// Reglas para limpiar y agrupar los nombres de modelo del catálogo de CONUEE.
///
/// Todos los patrones se aplican sobre el texto en minúsculas y sin acentos.
/// Las excepciones salen solo de casos vistos en los datos de 2025 y 2026.
class MexicoModelConfig {
  const MexicoModelConfig._();

  static const String wordSeparatorPattern = r'\s+';
  static const String parenthesisPattern = r'\([^)]*\)?';
  static const String unclosedParenthesisPattern = r'\([^)]*$';
  static const String noisePattern = r'[*,;]+';

  // Potencia, cilindrada, transmisión, tracción y electrificación, en cualquier posición.
  static const List<String> inlineRemovalPatterns = [
    r'\btraccion(?:\s+(?:delantera|trasera|integral))?\b',
    r'\b\d{2,4}\s?(?:hp|ps)\b',
    r'\b\d\.\d{1,2}\s?(?:lts|lt|l|t)?\b',
    r'\b(?:\d{2}\s+)?(?:tfsi|tsi|tdi|mpi|boostergreen)\b',
    r'\b(?:tiptronic|s[\s-]?tronic|pdk|dsg|e-cvt|cvt|ivt|automatico|automatica|aut)\b',
    r'\b\d{1,2}(?:at|mt|dct)\b',
    r'\b(?:manual|mt|at|ta|tm)\b',
    r'\bt/a\b',
    r'\br\d{2}\b',
    r'\b(?:4x4|4x2|4wd|2wd|awd|fwd|rwd|quattro|front|frontal|integral)\b',
    r'\b(?:mild[\s-]?hybrid|e[\s-]plug[\s-]?in|plug[\s-]?in|e[\s-]hybrid|hibrido|hybrid)\b',
    r'\b(?:phev|mhev|fhev|hev|reev|e[\s-]?rev|e[\s-]?power|i[\s-]?dm|dm[\s-]?[io]|dm)\b',
  ];

  // Palabras finales que describen una versión; se quitan hasta que no cambie nada.
  static const List<String> variantTrailingTokens = [
    'GL',
    'GLS',
    'GLX',
    'SE',
    'LIMITED',
    'TECH',
    'PREMIUM',
    'PLUS',
    'PRO',
    'MID',
    'ADVANCE',
    'SEDAN',
    'DIESEL',
    'GASOLINA',
  ];

  // Sufijos propios de una marca; la clave es la marca normalizada.
  static const Map<String, List<String>> brandVariantTrailingTokens = {
    'acura': ['A SPEC', 'ADVANCE', 'TYPE S'],
    'audi': ['PERFORMANCE', 'AVANT', 'SB', 'SPORTBACK', 'LWB'],
  };

  // Una letra suelta al final es una versión (AVEO A, TAHOE G, MACAN S).
  static const String trailingLetterPattern = r'^[a-z]$';

  // Palabras que se quitan al principio; Land Rover: 'NEW RANGE ROVER'.
  static const Map<String, List<String>> brandLeadingTokens = {
    'landrover': ['NEW'],
  };

  // Prefijos que se reescriben; clave = marca normalizada.
  static const Map<String, Map<String, String>> modelPrefixAliases = {
    'landrover': {'RANGE ROVER VELAR': 'VELAR', 'RANGE ROVER EVOQUE': 'EVOQUE'},
    'audi': {'RS 3': 'RS3', 'RS 6': 'RS6', 'RS 7': 'RS7', 'RS Q8': 'RSQ8'},
  };

  // Bases que absorben todo nombre que empieza con ellas; clave = marca normalizada.
  static const Map<String, List<String>> absorbingModelBases = {
    'porsche': [
      'CAYENNE',
      'MACAN',
      'PANAMERA',
      '911',
      '718',
      'CAYMAN',
      'BOXSTER',
    ],
  };

  // Familias que no se unen a un nombre más corto; clave = marca normalizada.
  static const Map<String, List<String>> protectedModelFamilies = {
    'toyota': ['COROLLA CROSS'],
    'landrover': ['RANGE ROVER SPORT', 'DISCOVERY SPORT'],
    'chevrolet': ['BLAZER EV', 'EXPRESS MAX EV'],
  };
}
