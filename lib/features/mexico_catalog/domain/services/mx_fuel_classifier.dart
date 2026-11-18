import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Clasifica el combustible de CONUEE y el nombre del modelo en un EngineKind.
class MxFuelClassifier {
  const MxFuelClassifier({this.onUnknown});

  /// Avisa de un combustible que no está en la tabla.
  final void Function(String original)? onUnknown;

  static final RegExp _pluginModel = RegExp(ConueeConfig.pluginModelPattern);

  /// Un enchufable o de autonomía extendida se reconoce por el nombre del modelo.
  static bool isPluginModel(String rawModel) =>
      _pluginModel.hasMatch(rawModel.toUpperCase());

  /// Nulo si el combustible no se conoce.
  EngineKind? classify(String? fuelType, String rawModel) {
    final trimmed = fuelType?.trim() ?? '';
    final name =
        ConueeConfig.fuelEngineKinds[TextNormalizer.normalize(trimmed)];
    final kind = name == null ? null : EngineKind.fromName(name);
    if (kind == null && trimmed.isNotEmpty) onUnknown?.call(trimmed);
    if (kind != EngineKind.electric && isPluginModel(rawModel)) {
      return EngineKind.pluginHybrid;
    }
    return kind;
  }
}
