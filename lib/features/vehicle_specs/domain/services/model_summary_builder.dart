import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/model_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/powertrain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_record_entity.dart';

/// Construye el resumen de un modelo a partir del registro de un vehículo.
class ModelSummaryBuilder {
  const ModelSummaryBuilder();

  ModelSummaryEntity build(VehicleRecordEntity record) {
    final powertrain = _classify(record.atvType);
    final mpg = record.combinedMpg;
    final isCombustion = powertrain == Powertrain.combustion;
    return ModelSummaryEntity(
      vehicleClass: record.vehicleClass,
      powertrain: powertrain,
      combinedKmPerLiter: isCombustion && mpg != null
          ? mpg * UnitsConfig.milesPerGallonToKilometersPerLiter
          : null,
    );
  }

  // Sin distinguir mayúsculas; un valor no listado es other.
  Powertrain _classify(String atvType) {
    final name =
        VehicleSpecsConfig.powertrainByAtvType[atvType.trim().toLowerCase()] ??
        VehicleSpecsConfig.otherPowertrainName;
    return Powertrain.values.firstWhere(
      (powertrain) => powertrain.name == name,
      orElse: () => Powertrain.other,
    );
  }
}
