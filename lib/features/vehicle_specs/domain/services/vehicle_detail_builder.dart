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
      annualFuelCostUsd: record.annualFuelCostUsd,
    );
  }

  double? _toKmPerLiter(double? mpg) {
    return mpg == null
        ? null
        : mpg * UnitsConfig.milesPerGallonToKilometersPerLiter;
  }
}
