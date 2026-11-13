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

  // La tabla sale de la muestra real y crece con casos nuevos.
  static const Map<String, String> vehicleClassLabels = {
    'Minicompact Cars': 'Minicompacto',
    'Subcompact Cars': 'Subcompacto',
    'Compact Cars': 'Compacto',
    'Midsize Cars': 'Mediano',
    'Large Cars': 'Grande',
    'Small Station Wagons': 'Familiar pequeña',
    'Small Sport Utility Vehicle 2WD': 'SUV pequeña 2WD',
    'Small Sport Utility Vehicle 4WD': 'SUV pequeña 4WD',
    'Standard Sport Utility Vehicle 2WD': 'SUV estándar 2WD',
    'Standard Sport Utility Vehicle 4WD': 'SUV estándar 4WD',
    'Small Pickup Trucks 2WD': 'Pickup pequeña 2WD',
    'Small Pickup Trucks 4WD': 'Pickup pequeña 4WD',
  };

  // Provisional: días de vigencia del resumen guardado.
  static const int summaryCacheTimeToLiveDays = 30;
}
