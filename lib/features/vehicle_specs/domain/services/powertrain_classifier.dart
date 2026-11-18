import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/powertrain.dart';

/// Clasifica el tipo de motorización a partir del atvType de la API.
class PowertrainClassifier {
  const PowertrainClassifier();

  // Sin distinguir mayúsculas; un valor no listado es other.
  Powertrain classify(String atvType) {
    final name =
        VehicleSpecsConfig.powertrainByAtvType[atvType.trim().toLowerCase()] ??
        VehicleSpecsConfig.otherPowertrainName;
    return Powertrain.values.firstWhere(
      (powertrain) => powertrain.name == name,
      orElse: () => Powertrain.other,
    );
  }

  /// Tipo de motorización para la insignia; nulo si el atvType no se conoce.
  EngineKind? engineKindOf(String atvType) {
    final name =
        VehicleSpecsConfig.engineKindByAtvType[atvType.trim().toLowerCase()];
    return name == null ? null : EngineKind.fromName(name);
  }
}
