/// Rutas, campos y tablas del resumen técnico de un modelo.
class VehicleSpecsConfig {
  const VehicleSpecsConfig._();

  // Rutas relativas a la URL base de FuelEconomy.
  static const String optionsPath = '/menu/options';
  static const String vehiclePathTemplate = '/{id}';
  static const String idPlaceholder = '{id}';
  static const String modelQueryParameter = 'model';
  static const String menuValueKey = 'value';

  // Campos del registro de un vehículo.
  static const String vehicleClassKey = 'VClass';
  static const String atvTypeKey = 'atvType';
  static const String combinedMpgKey = 'comb08';
  static const String combinedMpgPreciseKey = 'comb08U';
  static const String cityMpgKey = 'city08';
  static const String highwayMpgKey = 'highway08';
  static const String annualFuelCostKey = 'fuelCost08';
  static const String cylindersKey = 'cylinders';
  static const String displacementKey = 'displ';
  static const String transmissionKey = 'trany';
  static const String driveKey = 'drive';
  static const String fuelTypeKey = 'fuelType';
  static const String makeKey = 'make';
  static const String modelKey = 'model';
  static const String yearKey = 'year';

  // Nombre de la clasificación para cualquier atvType no listado.
  static const String otherPowertrainName = 'other';

  // Claves en minúsculas; el valor es el nombre del enum Powertrain.
  static const Map<String, String> powertrainByAtvType = {
    '': 'combustion',
    'ffv': 'combustion',
    'diesel': 'combustion',
    'hybrid': 'combustion',
    'ev': 'electric',
    'plug-in hybrid': 'pluginHybrid',
    'fcv': 'fuelCell',
    'efcv': 'fuelCell',
  };

  // Sufijo de tracción al final de la clase; se aplica sin distinguir mayúsculas.
  static const String driveSuffixPattern = r'\s*[-/]?\s*(2WD|4WD)$';

  // Registro de depuración de una clase sin traducción; va seguido del valor.
  static const String untranslatedClassLogPrefix = 'clase sin traducir: ';

  // Versión de la clave del resumen; 'v3' invalida lo guardado sin hasFuelCell.
  static const String summaryCacheKeyVersion = 'v3';

  // Provisional: días de vigencia del resumen guardado.
  static const int summaryCacheTimeToLiveDays = 30;

  // Versión de la clave del detalle de una versión.
  static const String vehicleDetailCacheKeyVersion = 'v1';

  // Provisional: días de vigencia del detalle guardado.
  static const int vehicleDetailCacheTimeToLiveDays = 30;
}
