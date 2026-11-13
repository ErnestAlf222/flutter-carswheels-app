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
  };

  // Clases de FuelEconomy sin sufijo de tracción; crece con casos nuevos.
  static const Map<String, String> vehicleClassLabels = {
    'Minicompact Cars': 'Minicompacto',
    'Subcompact Cars': 'Subcompacto',
    'Compact Cars': 'Compacto',
    'Midsize Cars': 'Mediano',
    'Large Cars': 'Grande',
    'Two Seaters': 'Dos plazas',
    'Small Station Wagons': 'Familiar pequeña',
    'Midsize Station Wagons': 'Familiar mediana',
    'Small SUV': 'SUV pequeña',
    'Standard SUV': 'SUV estándar',
    'Small Pickup Trucks': 'Pickup pequeña',
    'Small Pickup': 'Pickup pequeña',
    'Standard Pickup Trucks': 'Pickup estándar',
    'Standard Pickup': 'Pickup estándar',
    'Minivan': 'Minivan',
  };

  // Sufijo de tracción al final de la clase; se aplica sin distinguir mayúsculas.
  static const String driveSuffixPattern = r'\s*-?\s*(2WD|4WD)$';

  // Versión de la clave del resumen; 'v2' invalida las entradas de una sola variante.
  static const String summaryCacheKeyVersion = 'v2';

  // Provisional: días de vigencia del resumen guardado.
  static const int summaryCacheTimeToLiveDays = 30;
}
