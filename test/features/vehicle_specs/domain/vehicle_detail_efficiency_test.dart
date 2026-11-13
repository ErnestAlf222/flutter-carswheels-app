import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/real_efficiency_records.dart';

void main() {
  const builder = VehicleDetailBuilder();

  // Cadena real: JSON de la API, modelo, mapper y constructor de la ficha.
  VehicleDetailEntity build(Map<String, dynamic> json, int id) {
    final record = VehicleRecordMapper.toEntity(
      FuelEconomyVehicleModel.fromJson(json),
    );
    return builder.build(record, id, 2020, 'Marca', 'Modelo');
  }

  double km(double miles) => miles * UnitsConfig.kilometersPerMile;
  double gPerKm(double gramsPerMile) =>
      gramsPerMile / UnitsConfig.kilometersPerMile;
  double kwh(double per100Miles) =>
      per100Miles * UnitsConfig.kilowattHoursPer100MilesToPer100Kilometers;

  group('campos de consumo y emisiones con vehículos reales', () {
    test('Corolla: CO₂ en g/km y puntuaciones, sin campos eléctricos', () {
      final detail = build(realCorolla, 41213);
      expect(detail.powertrain, Powertrain.combustion);
      expect(detail.co2GramsPerKilometer, closeTo(gPerKm(257), 1e-9));
      expect(detail.fuelScore, 8);
      expect(detail.emissionsScore, 8);
      expect(detail.electricRangeKilometers, isNull);
      expect(detail.totalRangeKilometers, isNull);
      expect(detail.electricConsumptionKwhPer100Kilometers, isNull);
      expect(detail.hybridGasKmPerLiter, isNull);
      expect(detail.cityKmPerLiter, isNotNull);
    });

    test('Tesla: autonomía total, consumo eléctrico y CO₂ 0', () {
      final detail = build(realTesla, 42274);
      expect(detail.powertrain, Powertrain.electric);
      expect(detail.totalRangeKilometers, closeTo(km(330), 1e-9));
      expect(detail.electricRangeKilometers, isNull);
      expect(
        detail.electricConsumptionKwhPer100Kilometers,
        closeTo(kwh(25.8779), 1e-9),
      );
      expect(detail.co2GramsPerKilometer, 0);
      expect(detail.hybridGasKmPerLiter, isNull);
      expect(detail.cityKmPerLiter, isNull);
      expect(detail.fuelScore, 10);
      expect(detail.emissionsScore, 10);
    });

    test('Prius Prime: autonomía eléctrica, consumo y gasolina híbrida', () {
      final detail = build(realPriusPrime, 41489);
      expect(detail.powertrain, Powertrain.pluginHybrid);
      expect(detail.electricRangeKilometers, closeTo(km(25), 1e-9));
      expect(detail.totalRangeKilometers, isNull);
      expect(
        detail.electricConsumptionKwhPer100Kilometers,
        closeTo(kwh(25), 1e-9),
      );
      expect(
        detail.hybridGasKmPerLiter,
        closeTo(54.4329 * UnitsConfig.milesPerGallonToKilometersPerLiter, 1e-9),
      );
      expect(detail.co2GramsPerKilometer, closeTo(gPerKm(78), 1e-9));
      expect(detail.fuelScore, 10);
    });

    test('Mirai: autonomía total, sin CO₂ ni consumo eléctrico', () {
      final detail = build(realMirai, 47538);
      expect(detail.powertrain, Powertrain.fuelCell);
      expect(detail.totalRangeKilometers, closeTo(km(312), 1e-9));
      expect(detail.co2GramsPerKilometer, isNull);
      expect(detail.electricConsumptionKwhPer100Kilometers, isNull);
      expect(detail.electricRangeKilometers, isNull);
      expect(detail.fuelScore, 10);
      expect(detail.emissionsScore, 10);
    });

    test('Bolt: eléctrico con autonomía de 259 millas y CO₂ 0', () {
      final detail = build(realBolt, 42191);
      expect(detail.totalRangeKilometers, closeTo(km(259), 1e-9));
      expect(detail.co2GramsPerKilometer, 0);
      expect(
        detail.electricConsumptionKwhPer100Kilometers,
        closeTo(kwh(28.6629), 1e-9),
      );
    });

    test('F-150: CO₂ alto y puntuaciones bajas', () {
      final detail = build(realF150, 42171);
      expect(detail.co2GramsPerKilometer, closeTo(gPerKm(468), 1e-9));
      expect(detail.fuelScore, 3);
      expect(detail.emissionsScore, 3);
      expect(detail.totalRangeKilometers, isNull);
    });
  });

  group('valores ausentes o fuera de rango', () {
    test('la puntuación -1 queda nula', () {
      final detail = build({
        ...realCorolla,
        'feScore': '-1',
        'ghgScore': '-1',
      }, 1);
      expect(detail.fuelScore, isNull);
      expect(detail.emissionsScore, isNull);
    });

    test('puntuaciones 0 y 11 quedan nulas; 1 y 10 se conservan', () {
      expect(build({...realCorolla, 'feScore': '0'}, 1).fuelScore, isNull);
      expect(build({...realCorolla, 'feScore': '11'}, 1).fuelScore, isNull);
      expect(build({...realCorolla, 'feScore': '1'}, 1).fuelScore, 1);
      expect(build({...realCorolla, 'feScore': '10'}, 1).fuelScore, 10);
    });

    test('campos ausentes o vacíos quedan nulos', () {
      final detail = build({'atvType': 'EV', 'range': '', 'combE': '0.0'}, 1);
      expect(detail.totalRangeKilometers, isNull);
      expect(detail.electricConsumptionKwhPer100Kilometers, isNull);
      expect(detail.co2GramsPerKilometer, isNull);
      expect(detail.fuelScore, isNull);
    });

    test('autonomía 0 queda nula', () {
      expect(
        build({...realTesla, 'range': '0'}, 1).totalRangeKilometers,
        isNull,
      );
    });

    test('CO₂ 0 en un combustión es ausente; en un eléctrico se conserva', () {
      expect(
        build({
          ...realCorolla,
          'co2TailpipeGpm': '0.0',
        }, 1).co2GramsPerKilometer,
        isNull,
      );
      expect(build(realTesla, 1).co2GramsPerKilometer, 0);
    });

    test('enchufable sin autonomía eléctrica la deja nula', () {
      expect(
        build({...realPriusPrime, 'rangeA': ''}, 1).electricRangeKilometers,
        isNull,
      );
    });
  });
}
