import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/group_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/powertrain.dart';

/// Etiquetas de motorización de un resumen, una por tipo y en orden fijo.
class PowertrainLabelsResolver {
  const PowertrainLabelsResolver();

  /// Eléctrico, híbrido enchufable e hidrógeno; vacía si no aplica ninguno.
  List<String> labelsFor(GroupSummaryEntity summary) => [
    if (summary.hasElectric) AppTexts.electricLabel,
    if (summary.hasPluginHybrid) AppTexts.pluginHybridLabel,
    if (summary.hasFuelCell) AppTexts.hydrogenLabel,
  ];

  /// Etiqueta de motor de una versión; vacía para combustión u otro tipo.
  List<String> labelsForPowertrain(Powertrain powertrain) =>
      switch (powertrain) {
        Powertrain.electric => [AppTexts.electricLabel],
        Powertrain.pluginHybrid => [AppTexts.pluginHybridLabel],
        Powertrain.fuelCell => [AppTexts.hydrogenLabel],
        Powertrain.combustion || Powertrain.other => const [],
      };

  /// Verdadero si hay alguna motorización distinta de la combustión.
  bool hasAlternative(GroupSummaryEntity summary) =>
      summary.hasElectric || summary.hasPluginHybrid || summary.hasFuelCell;
}
