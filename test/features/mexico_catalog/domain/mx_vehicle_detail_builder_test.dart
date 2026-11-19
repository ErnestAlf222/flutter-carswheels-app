import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/conuee_test_support.dart';
import '../../../support/mx_detail_test_support.dart';

void main() {
  const builder = MxVehicleDetailBuilder();

  group('constructor de detalle de México', () {
    test('gasolina real: km/l, CO₂ por ciclo y textos limpios', () {
      final detail = mxDetail('COROLLA');
      expect(detail.powertrain, Powertrain.combustion);
      expect(detail.combinedKmPerLiter, 19.14);
      expect(detail.co2GramsPerKilometer, 119.0);
      expect(detail.cityCo2GramsPerKilometer, isNotNull);
      expect(detail.fuelType, 'Gasolina');
      expect(detail.cylindersLabel, '4 en línea');
      expect(detail.displacementCubicCentimeters, 1987);
      expect(detail.displacementLiters, closeTo(1.987, 1e-9));
      expect(detail.powerText, '198 @ 6600');
      expect(detail.compressionRatioText, '13.0:1');
    });

    test('no inventa clase, tracción, costo ni puntajes', () {
      final detail = mxDetail('COROLLA');
      expect(detail.vehicleClass, isNull);
      expect(detail.drive, isNull);
      expect(detail.annualFuelCostUsd, isNull);
      expect(detail.fuelScore, isNull);
      expect(detail.emissionsScore, isNull);
      expect(detail.electricRangeKilometers, isNull);
      expect(detail.electricConsumptionKwhPer100Kilometers, isNull);
    });

    test('híbrido real cuenta como combustión y conserva su km/l', () {
      final detail = mxDetail('COROLLA HIBRIDO');
      expect(detail.powertrain, Powertrain.combustion);
      expect(detail.combinedKmPerLiter, 31.31);
      expect(detail.fuelType, 'Híbrido');
    });

    test('E-POWER real cuenta como híbrido y sigue con km/l', () {
      final detail = mxDetail('KICKS PLAY E-POWER E-REV');
      expect(detail.powertrain, Powertrain.combustion);
      expect(detail.combinedKmPerLiter, isNotNull);
      // La grafía "Rg" no está confirmada: sale tal cual.
      expect(detail.transmission, 'Rg');
    });

    test('enchufable real no muestra km/l pero sí CO₂', () {
      final detail = mxDetail('OUTLANDER PHEV SE PLUS');
      expect(detail.powertrain, Powertrain.pluginHybrid);
      expect(detail.cityKmPerLiter, isNull);
      expect(detail.highwayKmPerLiter, isNull);
      expect(detail.combinedKmPerLiter, isNull);
      expect(detail.co2GramsPerKilometer, 44.0);
    });

    test('eléctrico real nunca lleva km/l ni CO₂ de relleno', () {
      final detail = mxDetail('LYRIQ F');
      expect(detail.powertrain, Powertrain.electric);
      expect(detail.combinedKmPerLiter, isNull);
      expect(detail.cityKmPerLiter, isNull);
      expect(detail.co2GramsPerKilometer, isNull);
      expect(detail.powerText, '503');
      expect(detail.torqueText, '710');
    });

    test(
      'el km/l crudo de un eléctrico se descarta aunque la fila lo traiga',
      () {
        // El Lyriq real trae 53.879 km/l: el constructor lo quita.
        final vehicle = conueeVehicle('LYRIQ F');
        expect(vehicle.combinedKmPerLiter, isNotNull);
        expect(builder.build(vehicle, 2025).combinedKmPerLiter, isNull);
      },
    );

    test('diésel real: km/l, CO₂ y compresión limpia', () {
      final detail = builder.build(dieselVehicle(0), 2025);
      expect(detail.powertrain, Powertrain.combustion);
      expect(detail.fuelType, 'Diésel');
      expect(detail.cityKmPerLiter, 12.16);
      expect(detail.highwayKmPerLiter, 14.86);
      expect(detail.combinedKmPerLiter, 13.24);
      expect(detail.highwayCo2GramsPerKilometer, 180.0);
      expect(detail.compressionRatioText, '16.5:1');
      expect(detail.powerText, '134 @ 3500');
    });

    test('campos con basura se omiten: compresión con ± y sin dos puntos', () {
      expect(
        builder.build(dieselVehicle(1), 2025).compressionRatioText,
        isNull,
      );
      expect(mxDetail('AVATR 07 (REEV) AWD').compressionRatioText, isNull);
      expect(mxDetail('SONG PRO DM-I').compressionRatioText, isNull);
      expect(mxDetail('SONG PRO DM-I').torqueText, isNull);
    });

    test(
      'un eléctrico con ceros de relleno no trae cilindros ni cilindrada',
      () {
        final detail = mxDetail('AVATR 11 AWD');
        expect(detail.cylindersLabel, isNull);
        expect(detail.displacementCubicCentimeters, isNull);
        expect(detail.displacementLiters, isNull);
        expect(detail.transmission, isNull);
      },
    );
  });

  group('limpieza de la relación de compresión', () {
    const cleaner = MxCompressionRatioCleaner();

    test('acepta número:1 con o sin espacios', () {
      expect(cleaner.clean('13.0:1'), '13.0:1');
      expect(cleaner.clean('10.5 : 1'), '10.5:1');
      expect(cleaner.clean('10:1'), '10:1');
    });

    test('descarta el resto', () {
      for (final raw in [
        '11.8',
        '0',
        '0:1',
        'sin dato',
        '12+-0.3',
        '(15.2±1.5):1',
        null,
      ]) {
        expect(cleaner.clean(raw), isNull, reason: '$raw');
      }
    });
  });
}
