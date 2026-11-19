/// Factores de conversión de unidades.
class UnitsConfig {
  const UnitsConfig._();

  static const double milesPerGallonToKilometersPerLiter = 0.425144;
  static const double kilometersPerMile = 1.609344;

  // Centímetros cúbicos por litro, para la cilindrada de México.
  static const double cubicCentimetersPerLiter = 1000.0;

  // kWh por 100 millas a kWh por 100 km: se divide entre los km de una milla.
  static const double kilowattHoursPer100MilesToPer100Kilometers =
      1 / kilometersPerMile;
}
