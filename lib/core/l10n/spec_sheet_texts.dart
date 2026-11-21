import 'package:cars_wheels_app/core/config/config.dart';

/// Textos de la ficha técnica enriquecida de Detalle.
class SpecSheetTexts {
  const SpecSheetTexts._();

  // Títulos de sección.
  static const String engineSection = 'Motor';
  static const String consumptionSection = 'Consumo';
  static const String energySection = 'Energía';
  static const String bodySection = 'Carrocería';

  // Nombres de fila.
  static const String cityConsumption = 'Consumo en ciudad';
  static const String highwayConsumption = 'Consumo en carretera';
  static const String combinedConsumption = 'Consumo combinado';
  static const String annualCost = 'Costo anual de combustible';
  static const String cityCo2 = 'CO₂ en ciudad';
  static const String highwayCo2 = 'CO₂ en carretera';
  static const String powertrain = 'Motorización';
  static const String chargeTime240 = 'Carga completa (240 V)';
  static const String chargeTime120 = 'Carga completa (120 V)';
  static const String startStop = 'Arranque-parada';
  static const String vehicleClass = 'Clase';
  static const String passengerVolume = 'Volumen de pasajeros';
  static const String cargoVolume = 'Volumen de carga';

  // Valores.
  static const String yes = 'Sí';
  static const String no = 'No';
  static const String mpgUnit = 'mpg';
  static const String hoursUnit = 'h';
  static const String litersUnit = 'L';
  static const String consumptionSeparator = ' · ';

  /// Consumo en km/l con su equivalente en mpg, por ejemplo '9.5 km/l · 22.4 mpg'.
  static String kmPerLiterWithMpg(double kmPerLiter) {
    final mpg = kmPerLiter / UnitsConfig.milesPerGallonToKilometersPerLiter;
    final km = kmPerLiter.toStringAsFixed(TextConfig.kmPerLiterFractionDigits);
    final miles = mpg.toStringAsFixed(TextConfig.kmPerLiterFractionDigits);
    // Espacios sin salto: el renglón solo se parte en el separador.
    return '$km km/l$consumptionSeparator$miles $mpgUnit';
  }

  /// Consumo solo en km/l, por ejemplo '14.3 km/l'.
  static String kmPerLiterOnly(double kmPerLiter) =>
      '${kmPerLiter.toStringAsFixed(TextConfig.kmPerLiterFractionDigits)} km/l';

  /// Horas con un decimal, por ejemplo '10.4 h'.
  static String hoursFigure(double hours) =>
      '${hours.toStringAsFixed(TextConfig.chargeHoursFractionDigits)} $hoursUnit';

  /// Litros enteros con separador de miles, por ejemplo '2,830 L'.
  static String litersFigure(double liters) {
    final grouped = liters.round().toString().replaceAllMapped(
      RegExp(TextConfig.thousandsBoundaryPattern),
      (_) => TextConfig.thousandsSeparator,
    );
    return '$grouped $litersUnit';
  }
}
