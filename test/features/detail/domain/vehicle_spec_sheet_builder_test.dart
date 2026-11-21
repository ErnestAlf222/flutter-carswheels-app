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

  List<String> labels(List<SpecEntryEntity> entries) => [
    for (final entry in entries) entry.label,
  ];

  test(
    'EE. UU.: combustión muestra motor, transmisión, tracción y combustible',
    () {
      final entries = builder.build(testDetail(), isMexico: false);
      expect(
        labels(entries),
        containsAll([
          AppTexts.detailFuelRowLabel,
          AppTexts.detailCylindersRowLabel,
          AppTexts.detailDisplacementRowLabel,
          AppTexts.detailTransmissionRowLabel,
          AppTexts.detailDriveRowLabel,
        ]),
      );
      expect(labels(entries), isNot(contains(AppTexts.electricRangeLabel)));
    },
  );

  group('EE. UU.: aspiración', () {
    String? aspiration({bool turbo = false, bool supercharger = false}) {
      final entries = builder.build(
        testDetail(hasTurbo: turbo, hasSupercharger: supercharger),
        isMexico: false,
      );
      final matches = entries.where(
        (entry) => entry.label == AppTexts.detailAspirationRowLabel,
      );
      return matches.isEmpty ? null : matches.single.value;
    }

    test('sin turbo ni supercargador la fila no aparece', () {
      expect(aspiration(), isNull);
    });

    test('con turbo, con supercargador o con ambos', () {
      expect(aspiration(turbo: true), AppTexts.aspirationTurbo);
      expect(aspiration(supercharger: true), AppTexts.aspirationSupercharger);
      expect(
        aspiration(turbo: true, supercharger: true),
        AppTexts.aspirationBoth,
      );
    });

    test('México nunca muestra la fila de aspiración', () {
      final entries = builder.build(testDetail(hasTurbo: true), isMexico: true);
      expect(
        labels(entries),
        isNot(contains(AppTexts.detailAspirationRowLabel)),
      );
    });
  });

  test('EE. UU.: eléctrico suma autonomía y consumo; lo nulo no aparece', () {
    final entries = builder.build(
      testDetail(
        powertrain: Powertrain.electric,
        cylinders: null,
        displacementLiters: null,
        fuelType: 'Electricity',
        totalRangeKilometers: 480,
        electricConsumptionKwhPer100Kilometers: 16.5,
      ),
      isMexico: false,
    );
    expect(
      labels(entries),
      containsAll([
        AppTexts.totalRangeLabel,
        AppTexts.electricConsumptionLabel,
      ]),
    );
    expect(labels(entries), isNot(contains(AppTexts.detailCylindersRowLabel)));
    expect(
      entries.every(
        (entry) =>
            entry.value.trim().isNotEmpty &&
            entry.value != AppTexts.noDataLabel,
      ),
      isTrue,
    );
  });

  test('México: potencia, torque y compresión salen de CONUEE', () {
    final entries = builder.build(
      testDetail(
        fuelType: 'Gasolina',
        cylindersLabel: '4 cil',
        powerText: '190 @ 6000',
        torqueText: '350 @ 1500-4000',
        compressionRatioText: '10.5:1',
        transmission: 'Automática',
      ),
      isMexico: true,
    );
    expect(
      labels(entries),
      containsAll([
        AppTexts.detailPowerRowLabel,
        AppTexts.detailTorqueRowLabel,
        AppTexts.detailCompressionRowLabel,
      ]),
    );
  });

  test('una versión sin ningún dato da una lista vacía (sin burbuja)', () {
    final empty = testDetail(
      transmission: null,
      cylinders: null,
      displacementLiters: null,
      drive: null,
      fuelType: null,
    );
    expect(builder.build(empty, isMexico: false), isEmpty);
    expect(builder.build(empty, isMexico: true), isEmpty);
  });
}
