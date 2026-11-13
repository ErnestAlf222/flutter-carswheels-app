import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/powertrain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_detail_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_record_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/services/powertrain_classifier.dart';

/// Construye la ficha de una versión a partir de su registro.
class VehicleDetailBuilder {
  const VehicleDetailBuilder({this.classifier = const PowertrainClassifier()});

  final PowertrainClassifier classifier;

  /// Año, marca y modelo son los de la opción pedida, no los del registro.
  VehicleDetailEntity build(
    VehicleRecordEntity record,
    int id,
    int year,
    String brand,
    String model,
  ) {
    final powertrain = classifier.classify(record.atvType);
    final isCombustion = powertrain == Powertrain.combustion;
    final isElectric = powertrain == Powertrain.electric;
    final isPluginHybrid = powertrain == Powertrain.pluginHybrid;
    final isFuelCell = powertrain == Powertrain.fuelCell;
    final hasCo2 = isCombustion || isElectric || isPluginHybrid;
    return VehicleDetailEntity(
      id: id,
      year: year,
      make: brand,
      model: model,
      vehicleClass: record.vehicleClass,
      powertrain: powertrain,
      transmission: record.transmission,
      cylinders: record.cylinders,
      displacementLiters: record.displacementLiters,
      drive: record.drive,
      fuelType: record.fuelType,
      cityKmPerLiter: isCombustion ? _toKmPerLiter(record.cityMpg) : null,
      highwayKmPerLiter: isCombustion ? _toKmPerLiter(record.highwayMpg) : null,
      combinedKmPerLiter: isCombustion
          ? _toKmPerLiter(record.combinedMpg)
          : null,
      annualFuelCostUsd: _validCost(record.annualFuelCostUsd),
      co2GramsPerKilometer: hasCo2
          ? _co2PerKilometer(record.co2GramsPerMile, keepZero: isElectric)
          : null,
      electricRangeKilometers: isPluginHybrid
          ? _milesToKilometers(_positive(record.electricRangeMiles))
          : null,
      totalRangeKilometers: isElectric || isFuelCell
          ? _milesToKilometers(_positive(record.totalRangeMiles))
          : null,
      electricConsumptionKwhPer100Kilometers: isElectric || isPluginHybrid
          ? _consumptionPer100Kilometers(
              record.electricConsumptionKwhPer100Miles,
            )
          : null,
      hybridGasKmPerLiter: isPluginHybrid
          ? _toKmPerLiter(_positive(record.combinedMpg))
          : null,
      fuelScore: _validScore(record.fuelEconomyScore),
      emissionsScore: _validScore(record.greenhouseGasScore),
    );
  }

  // Un costo de 0 es un dato no calculado (hidrógeno), no un costo real.
  int? _validCost(int? cost) => cost == null || cost <= 0 ? null : cost;

  double? _positive(double? value) =>
      value == null || value <= 0 ? null : value;

  double? _milesToKilometers(double? miles) =>
      miles == null ? null : miles * UnitsConfig.kilometersPerMile;

  // El CO₂ llega en g/mi; un 0 solo es dato real en un eléctrico.
  double? _co2PerKilometer(double? gramsPerMile, {required bool keepZero}) {
    if (gramsPerMile == null || gramsPerMile < 0) return null;
    if (gramsPerMile == 0 && !keepZero) return null;
    return gramsPerMile / UnitsConfig.kilometersPerMile;
  }

  double? _consumptionPer100Kilometers(double? kwhPer100Miles) {
    final valid = _positive(kwhPer100Miles);
    return valid == null
        ? null
        : valid * UnitsConfig.kilowattHoursPer100MilesToPer100Kilometers;
  }

  // Fuera de la escala (por ejemplo -1) es un dato ausente.
  int? _validScore(int? score) {
    final inRange =
        score != null &&
        score >= VehicleSpecsConfig.scoreMin &&
        score <= VehicleSpecsConfig.scoreMax;
    return inRange ? score : null;
  }

  double? _toKmPerLiter(double? mpg) {
    return mpg == null
        ? null
        : mpg * UnitsConfig.milesPerGallonToKilometersPerLiter;
  }
}
