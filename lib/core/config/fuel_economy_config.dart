/// Rutas y claves de la API FuelEconomy.
class FuelEconomyConfig {
  const FuelEconomyConfig._();

  // Año con el que arranca EE. UU.: el más reciente (2027) trae catálogo parcial.
  static const int defaultYear = 2026;

  static const String fuelEconomySourceLabel = 'fuel_economy';
  static const String menuYearPath = '/menu/year';
  static const String menuMakePath = '/menu/make';
  static const String menuModelPath = '/menu/model';
  static const String yearQueryParameter = 'year';
  static const String makeQueryParameter = 'make';
  static const String menuItemKey = 'menuItem';
  static const String itemTextKey = 'text';
}
