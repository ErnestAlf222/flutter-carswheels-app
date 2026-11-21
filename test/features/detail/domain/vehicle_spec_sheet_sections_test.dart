import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/detail_test_support.dart';

void main() {
  const builder = VehicleSpecSheetBuilder(
    transmissionLabeler: TransmissionLabeler(),
    fuelTypeLabeler: FuelTypeLabeler(),
    driveLabeler: DriveLabeler(),
  );

  SpecEntryEntity? entry(List<SpecEntryEntity> list, SpecKind kind) {
    final matches = list.where((e) => e.kind == kind);
    return matches.isEmpty ? null : matches.first;
  }

  test('EE. UU. gasolina: consumo con km/l y mpg, costo y clase', () {
    final entries = builder.build(
      testDetail(
        cityKmPerLiter: 9.5,
        highwayKmPerLiter: 14.0,
        engineKind: EngineKind.gasoline,
        passengerVolumeLiters: 2832,
        cargoVolumeLiters: 425,
        hasStartStop: true,
      ),
      isMexico: false,
    );
    expect(
      entry(entries, SpecKind.cityConsumption)!.value,
      SpecSheetTexts.kmPerLiterWithMpg(9.5),
    );
    expect(entry(entries, SpecKind.cityConsumption)!.value, contains('mpg'));
    expect(entry(entries, SpecKind.annualCost)!.value, r'$1,750');
    expect(entry(entries, SpecKind.vehicleClass)!.value, isNotEmpty);
    expect(entry(entries, SpecKind.passengerVolume)!.value, '2,832 L');
    expect(entry(entries, SpecKind.startStop)!.value, SpecSheetTexts.yes);
    expect(entry(entries, SpecKind.fuel)!.engineKindName, 'gasoline');
  });

  test('las secciones salen en orden y sin mezclarse', () {
    final entries = builder.build(
      testDetail(cityKmPerLiter: 9.5, engineKind: EngineKind.gasoline),
      isMexico: false,
    );
    final order = [for (final e in entries) e.section.index];
    expect(order, [...order]..sort());
    expect(entries.map((e) => e.section).toSet(), {
      SpecSection.engine,
      SpecSection.consumption,
      SpecSection.energy,
      SpecSection.body,
    });
  });

  test('eléctrico: la energía se llama Eléctrico con carga y autonomía', () {
    final entries = builder.build(
      testDetail(
        powertrain: Powertrain.electric,
        engineKind: EngineKind.electric,
        fuelType: 'Electricity',
        cylinders: null,
        displacementLiters: null,
        combinedKmPerLiter: null,
        totalRangeKilometers: 437,
        chargeHours240: 10.4,
        co2GramsPerKilometer: 0,
      ),
      isMexico: false,
    );
    expect(entry(entries, SpecKind.fuel)!.value, AppTexts.electricLabel);
    expect(entry(entries, SpecKind.chargeTime)!.value, '10.4 h');
    expect(entry(entries, SpecKind.totalRange)!.value, '437 km');
    expect(entry(entries, SpecKind.co2)!.value, '0 g/km');
    expect(entry(entries, SpecKind.cylinders), isNull);
    expect(entry(entries, SpecKind.cityConsumption), isNull);
  });

  test('enchufable: añade la motorización y el consumo con gasolina', () {
    final entries = builder.build(
      testDetail(
        powertrain: Powertrain.pluginHybrid,
        engineKind: EngineKind.pluginHybrid,
        hybridGasKmPerLiter: 20.0,
        electricRangeKilometers: 64,
      ),
      isMexico: false,
    );
    expect(
      entry(entries, SpecKind.powertrain)!.value,
      AppTexts.engineKindLabels['pluginHybrid'],
    );
    expect(entry(entries, SpecKind.hybridGasConsumption), isNotNull);
    expect(entry(entries, SpecKind.electricRange)!.value, '64 km');
  });

  test('México: consumo solo en km/l y CO₂ por ciclo; sin mpg ni costo', () {
    final entries = builder.build(
      testDetail(
        cityKmPerLiter: 14.3,
        highwayKmPerLiter: 18.6,
        combinedKmPerLiter: 16.0,
        co2GramsPerKilometer: 145,
        cityCo2GramsPerKilometer: 164,
        highwayCo2GramsPerKilometer: 126,
        cylindersLabel: '4 en línea',
        annualFuelCostUsd: null,
        vehicleClass: null,
        fuelType: 'Gasolina',
      ),
      isMexico: true,
    );
    expect(entry(entries, SpecKind.cityConsumption)!.value, '14.3 km/l');
    expect(entry(entries, SpecKind.cityCo2)!.value, '164 g/km');
    expect(entry(entries, SpecKind.highwayCo2)!.value, '126 g/km');
    expect(entry(entries, SpecKind.annualCost), isNull);
    expect(entry(entries, SpecKind.vehicleClass), isNull);
  });

  test('los nulos no generan fila ni se vuelven 0', () {
    final entries = builder.build(
      testDetail(
        passengerVolumeLiters: null,
        chargeHours240: null,
        hasStartStop: null,
        annualFuelCostUsd: null,
      ),
      isMexico: false,
    );
    expect(entry(entries, SpecKind.passengerVolume), isNull);
    expect(entry(entries, SpecKind.chargeTime), isNull);
    expect(entry(entries, SpecKind.startStop), isNull);
    expect(entry(entries, SpecKind.annualCost), isNull);
  });
}
