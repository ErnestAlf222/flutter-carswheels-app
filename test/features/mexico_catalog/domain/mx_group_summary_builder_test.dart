import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

MxVersionEntity _version(
  EngineKind? kind, {
  double? km,
  String? fuel,
  String label = 'V',
}) => MxVersionEntity(
  label: label,
  vehicle: MxVehicleEntity(
    id: 0,
    brand: 'Marca',
    rawModel: 'MODELO $label',
    model: 'MODELO',
    engineKind: kind,
    fuelType: fuel,
    combinedKmPerLiter: km,
  ),
);

void main() {
  const builder = MxGroupSummaryBuilder();

  test('sin versiones no hay resumen', () {
    expect(builder.build(const []), isNull);
  });

  test('rango de km/l solo de combustión e híbridos', () {
    final summary = builder.build([
      _version(EngineKind.gasoline, km: 12.4, fuel: 'Gasolina'),
      _version(EngineKind.hybrid, km: 20.9, fuel: 'Híbrido'),
      _version(EngineKind.diesel, km: 9.6, fuel: 'Diesel'),
      _version(EngineKind.electric, km: 5.0, fuel: 'Eléctrico'),
      _version(EngineKind.pluginHybrid, km: 30.0, fuel: 'Gasolina'),
    ])!;
    expect(summary.minKmPerLiter, 9.6);
    expect(summary.maxKmPerLiter, 20.9);
    expect(summary.variantCount, 5);
    expect(summary.vehicleClass, isNull);
    expect(summary.hasElectric, isTrue);
    expect(summary.hasPluginHybrid, isTrue);
    expect(summary.engineKinds, [
      EngineKind.electric,
      EngineKind.pluginHybrid,
      EngineKind.hybrid,
      EngineKind.diesel,
      EngineKind.gasoline,
    ]);
  });

  test('eléctrico y enchufable solos nunca llevan km/l', () {
    final electric = builder.build([
      _version(EngineKind.electric, km: 3.0, fuel: 'Eléctrico'),
    ])!;
    expect(electric.minKmPerLiter, isNull);
    expect(electric.maxKmPerLiter, isNull);
    final plugin = builder.build([
      _version(EngineKind.pluginHybrid, km: 25.0, fuel: 'Gasolina'),
    ])!;
    expect(plugin.minKmPerLiter, isNull);
    expect(plugin.hasPluginHybrid, isTrue);
  });

  test('versiones de combustión sin km/l dejan el rango nulo', () {
    final summary = builder.build([_version(EngineKind.gasoline)])!;
    expect(summary.minKmPerLiter, isNull);
    expect(summary.fuelLabel, isNull);
  });

  test('la línea de combustible va traducida, del más frecuente al menos', () {
    final summary = builder.build([
      _version(EngineKind.diesel, fuel: 'Diesel', label: 'A'),
      _version(EngineKind.gasoline, fuel: 'Gasolina', label: 'B'),
      _version(EngineKind.gasoline, fuel: 'Gasolina', label: 'C'),
    ])!;
    expect(
      summary.fuelLabel,
      '${AppTexts.gasolineLabel}${AppTexts.fuelListSeparator}'
      '${AppTexts.dieselLabel}',
    );
    final single = builder.build([
      _version(EngineKind.gasoline, fuel: 'Gasolina'),
    ])!;
    expect(single.fuelLabel, 'Gasolina');
  });

  test('un combustible que no está en la tabla se muestra tal cual', () {
    final summary = builder.build([_version(null, fuel: 'Biogás')])!;
    expect(summary.fuelLabel, 'Biogás');
  });
}
