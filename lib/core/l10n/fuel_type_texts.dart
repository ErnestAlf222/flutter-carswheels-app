/// Traducciones del tipo de combustible (campo fuelType) de FuelEconomy.
class FuelTypeTexts {
  const FuelTypeTexts._();

  // Sale del análisis de vehicles.csv del 2026-11-13; un valor ausente se muestra en inglés.
  // Clave: el valor original de fuelType; valor: traducción de máximo 32 caracteres.
  static const Map<String, String> labels = {
    'Regular': 'Gasolina regular',
    'Premium': 'Gasolina premium',
    'Midgrade': 'Gasolina media',
    'Diesel': 'Diésel',
    'Electricity': 'Electricidad',
    'Hydrogen': 'Hidrógeno',
    'CNG': 'Gas natural',
    'Gasoline or E85': 'Gasolina o E85',
    'Premium or E85': 'Gasolina premium o E85',
    'Gasoline or natural gas': 'Gasolina o gas natural',
    'Gasoline or propane': 'Gasolina o propano',
    'Premium and Electricity': 'Gasolina premium y electricidad',
    'Regular Gas and Electricity': 'Gasolina regular y electricidad',
    'Premium Gas or Electricity': 'Gasolina premium o electricidad',
    'Regular Gas or Electricity': 'Gasolina regular o electricidad',
    'Electricity and Hydrogen': 'Electricidad e hidrógeno',
  };
}
