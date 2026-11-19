import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_vehicle_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Construye la ficha de una versión de México; no inventa lo que CONUEE no trae.
class MxVehicleDetailBuilder {
  const MxVehicleDetailBuilder();

  // Solo estas motorizaciones tienen un km/l comparable.
  static const Set<EngineKind> _kmPerLiterKinds = {
    EngineKind.gasoline,
    EngineKind.diesel,
    EngineKind.hybrid,
    EngineKind.flexFuel,
  };

  /// El combustible ya sale en español en fuelType; no hay clase, tracción ni puntajes.
  VehicleDetailEntity build(MxVehicleEntity vehicle, int year) {
    final kind = vehicle.engineKind;
    final powertrain = powertrainFor(kind);
    // Con combustible desconocido se conserva el km/l que pasó la limpieza.
    final hasKmPerLiter = kind == null || _kmPerLiterKinds.contains(kind);
    final cubicCentimeters = vehicle.displacementCubicCentimeters;
    return VehicleDetailEntity(
      id: vehicle.id,
      year: year,
      make: vehicle.brand,
      model: vehicle.model,
      vehicleClass: null,
      powertrain: powertrain,
      transmission: vehicle.transmission,
      cylinders: null,
      displacementLiters: cubicCentimeters == null
          ? null
          : cubicCentimeters / UnitsConfig.cubicCentimetersPerLiter,
      drive: null,
      fuelType: _fuelLabel(vehicle.fuelType),
      cityKmPerLiter: hasKmPerLiter ? vehicle.cityKmPerLiter : null,
      highwayKmPerLiter: hasKmPerLiter ? vehicle.highwayKmPerLiter : null,
      combinedKmPerLiter: hasKmPerLiter ? vehicle.combinedKmPerLiter : null,
      annualFuelCostUsd: null,
      co2GramsPerKilometer: vehicle.combinedCo2GramsPerKilometer,
      cylindersLabel: vehicle.cylinders,
      displacementCubicCentimeters: cubicCentimeters,
      cityCo2GramsPerKilometer: vehicle.cityCo2GramsPerKilometer,
      highwayCo2GramsPerKilometer: vehicle.highwayCo2GramsPerKilometer,
      powerText: vehicle.power,
      torqueText: vehicle.torque,
      compressionRatioText: vehicle.compressionRatio,
    );
  }

  /// Motorización de la pantalla; el E-POWER y los híbridos cuentan como combustión.
  Powertrain powertrainFor(EngineKind? kind) => switch (kind) {
    EngineKind.electric => Powertrain.electric,
    EngineKind.pluginHybrid => Powertrain.pluginHybrid,
    EngineKind.hydrogen => Powertrain.fuelCell,
    _ => Powertrain.combustion,
  };

  // Combustible de CONUEE en español; lo no listado se muestra tal cual.
  String? _fuelLabel(String? raw) {
    if (raw == null) return null;
    return AppTexts.mexicoFuelLabels[TextNormalizer.normalize(raw)] ?? raw;
  }
}
