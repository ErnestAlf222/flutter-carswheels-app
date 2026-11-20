import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/compare/domain/entities/compare_engine_kind.dart';

/// Datos comparables de un vehículo; todo es opcional y nulo significa sin dato.
class CompareVehicleDetailEntity extends Equatable {
  const CompareVehicleDetailEntity({
    this.versionLabel,
    this.engineKind,
    this.combinedKmPerLiter,
    this.cityKmPerLiter,
    this.highwayKmPerLiter,
    this.co2GramsPerKilometer,
    this.fuelLabel,
    this.cylindersLabel,
    this.transmissionLabel,
    this.driveLabel,
    this.classLabel,
    this.annualFuelCostUsd,
    this.safetyStars,
    this.powerLabel,
    this.torqueLabel,
    this.compressionLabel,
  });

  /// Nombre legible de la versión que se está comparando.
  final String? versionLabel;
  final CompareEngineKind? engineKind;

  /// Consumos en km/l; nulos en eléctricos y cuando no hay dato.
  final double? combinedKmPerLiter;
  final double? cityKmPerLiter;
  final double? highwayKmPerLiter;

  /// CO₂ en g/km; el 0 de un eléctrico es un dato real.
  final double? co2GramsPerKilometer;

  /// Textos ya traducidos para mostrar.
  final String? fuelLabel;
  final String? cylindersLabel;
  final String? transmissionLabel;
  final String? driveLabel;
  final String? classLabel;

  /// Costo anual de combustible en dólares (solo EE. UU.).
  final int? annualFuelCostUsd;

  /// Estrellas generales NHTSA (solo EE. UU.).
  final int? safetyStars;

  /// Solo México: potencia, torque y compresión ya listos para mostrar.
  final String? powerLabel;
  final String? torqueLabel;
  final String? compressionLabel;

  /// Copia con las estrellas de seguridad, que llegan de otra fuente.
  CompareVehicleDetailEntity withSafetyStars(int? stars) =>
      CompareVehicleDetailEntity(
        versionLabel: versionLabel,
        engineKind: engineKind,
        combinedKmPerLiter: combinedKmPerLiter,
        cityKmPerLiter: cityKmPerLiter,
        highwayKmPerLiter: highwayKmPerLiter,
        co2GramsPerKilometer: co2GramsPerKilometer,
        fuelLabel: fuelLabel,
        cylindersLabel: cylindersLabel,
        transmissionLabel: transmissionLabel,
        driveLabel: driveLabel,
        classLabel: classLabel,
        annualFuelCostUsd: annualFuelCostUsd,
        safetyStars: stars,
        powerLabel: powerLabel,
        torqueLabel: torqueLabel,
        compressionLabel: compressionLabel,
      );

  @override
  List<Object?> get props => [
    versionLabel,
    engineKind,
    combinedKmPerLiter,
    cityKmPerLiter,
    highwayKmPerLiter,
    co2GramsPerKilometer,
    fuelLabel,
    cylindersLabel,
    transmissionLabel,
    driveLabel,
    classLabel,
    annualFuelCostUsd,
    safetyStars,
    powerLabel,
    torqueLabel,
    compressionLabel,
  ];
}
