/// Reglas para agrupar las variantes de modelo de FuelEconomy.
///
/// Son las reglas medidas con datos reales de FuelEconomy (Toyota 2020: 51
/// nombres a 17 grupos; Jeep 2020: 16 a 6; Hyundai 2020: 25 a 11). La lista de
/// excepciones crece con los casos reales.
class ModelGroupingConfig {
  const ModelGroupingConfig._();

  // Palabras o frases finales que describen una variante; sin distinguir mayúsculas.
  static const List<String> variantTrailingTokens = [
    '2WD',
    '4WD',
    'AWD',
    'FWD',
    'RWD',
    '4x4',
    '2Dr',
    '4Dr',
    '5Dr',
    'quattro',
    'ultra',
    'electric',
    'hybrid',
    'sedan',
    'wagon',
    'coupe',
    'convertible',
    'avant',
    'twin motor',
    // BMW 2020: '228i xDrive Gran Coupe', '640i xDrive Gran Turismo'.
    'gran coupe',
    'gran turismo',
  ];

  // Sufijos propios de una marca; la clave es la marca normalizada.
  static const Map<String, List<String>> brandVariantTrailingTokens = {
    'audi': ['TFSI', 'Sport', 'Performance'],
    // BMW 2020: 'X1 xDrive28i', 'M2 Competition'.
    'bmw': ['xDrive', 'sDrive', 'Competition'],
  };

  // Patrones (sin distinguir mayúsculas) de UNA palabra final; clave = marca normalizada.
  static const Map<String, List<String>> brandVariantTrailingPatterns = {
    // BMW 2020: 'X1 sDrive28i', 'X5 xDrive40i'.
    'bmw': [r'^[xs]drive\d+[a-z]*$'],
  };

  // Palabras que se quitan de cualquier posición; Audi 2027: 'Q6 Sportback e-tron'.
  static const List<String> variantInlineTokens = ['Sportback'];

  // Bases que absorben todo nombre que empieza con ellas; clave = marca normalizada.
  static const Map<String, List<String>> absorbingModelBases = {
    // Ford 2020: 'F150 Pickup 4WD', 'Transit T150 Wagon 2WD FFV', 'Transit Connect Van'.
    'ford': ['Transit Connect', 'Transit', 'F150', 'F250', 'F350'],
  };

  // Nombre a mostrar por clave normalizada del nombre base; clave = marca normalizada.
  static const Map<String, Map<String, String>> groupDisplayNames = {
    'ford': {'f150': 'F-150', 'f250': 'F-250', 'f350': 'F-350'},
  };

  // Familias que no se unen a un nombre más corto; la clave es la marca normalizada.
  static const Map<String, List<String>> protectedModelFamilies = {
    'landrover': [
      'Range Rover Sport',
      'Range Rover Evoque',
      'Range Rover Velar',
      'Discovery Sport',
    ],
    // Volkswagen 2027: 'Atlas' y 'Atlas Cross Sport 4motion' son modelos distintos.
    'volkswagen': ['Atlas Cross Sport'],
  };

  static const String parenthesisPattern = r'\([^)]*\)';
  static const String wordSeparatorPattern = r'\s+';
}
