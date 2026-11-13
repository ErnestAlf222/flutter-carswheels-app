import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = PowertrainLabelsResolver();

  test('cada motorización alternativa tiene su etiqueta', () {
    expect(resolver.labelsForPowertrain(Powertrain.electric), [
      AppTexts.electricLabel,
    ]);
    expect(resolver.labelsForPowertrain(Powertrain.pluginHybrid), [
      AppTexts.pluginHybridLabel,
    ]);
    expect(resolver.labelsForPowertrain(Powertrain.fuelCell), [
      AppTexts.hydrogenLabel,
    ]);
  });

  test('combustión y otros no tienen etiqueta', () {
    expect(resolver.labelsForPowertrain(Powertrain.combustion), isEmpty);
    expect(resolver.labelsForPowertrain(Powertrain.other), isEmpty);
  });
}
