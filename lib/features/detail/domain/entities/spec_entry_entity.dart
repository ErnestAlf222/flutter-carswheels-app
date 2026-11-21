import 'package:equatable/equatable.dart';

/// Sección de la ficha técnica en la que se agrupa cada fila.
enum SpecSection { engine, consumption, energy, body }

/// Tipo de dato de una fila; la presentación lo traduce a su ícono.
enum SpecKind {
  fuel,
  powertrain,
  cylinders,
  displacement,
  aspiration,
  transmission,
  drive,
  power,
  torque,
  compression,
  startStop,
  cityConsumption,
  highwayConsumption,
  combinedConsumption,
  hybridGasConsumption,
  electricConsumption,
  annualCost,
  electricRange,
  totalRange,
  chargeTime,
  co2,
  cityCo2,
  highwayCo2,
  vehicleClass,
  passengerVolume,
  cargoVolume,
}

/// Una fila de la ficha técnica: tipo, sección, nombre del dato y su valor ya legible.
class SpecEntryEntity extends Equatable {
  const SpecEntryEntity({
    required this.label,
    required this.value,
    this.kind = SpecKind.fuel,
    this.section = SpecSection.engine,
    this.engineKindName,
  });

  final String label;
  final String value;
  final SpecKind kind;
  final SpecSection section;

  /// Solo en la fila de combustible: nombre del EngineKind para elegir su ícono.
  final String? engineKindName;

  @override
  List<Object?> get props => [label, value, kind, section, engineKindName];
}
