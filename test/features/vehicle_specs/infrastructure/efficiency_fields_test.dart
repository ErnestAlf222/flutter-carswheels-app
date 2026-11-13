import 'dart:io';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../support/isar_test_support.dart';
import '../../../support/real_efficiency_records.dart';

void main() {
  group('modelo y mapper del registro con los campos nuevos', () {
    test('lee los campos reales del Prius Prime', () {
      final model = FuelEconomyVehicleModel.fromJson(realPriusPrime);
      expect(model.electricRange, '25');
      expect(model.totalRange, '640');
      expect(model.electricConsumption, '25.0');
      expect(model.co2TailpipeGramsPerMile, '78.0');
      expect(model.fuelEconomyScore, '10');
      expect(model.greenhouseGasScore, '10');
      final record = VehicleRecordMapper.toEntity(model);
      expect(record.electricRangeMiles, 25);
      expect(record.totalRangeMiles, 640);
      expect(record.electricConsumptionKwhPer100Miles, 25);
      expect(record.co2GramsPerMile, 78);
      expect(record.fuelEconomyScore, 10);
      expect(record.greenhouseGasScore, 10);
    });

    test('campos ausentes quedan nulos sin lanzar', () {
      final record = VehicleRecordMapper.toEntity(
        FuelEconomyVehicleModel.fromJson(const <String, dynamic>{}),
      );
      expect(record.electricRangeMiles, isNull);
      expect(record.totalRangeMiles, isNull);
      expect(record.electricConsumptionKwhPer100Miles, isNull);
      expect(record.co2GramsPerMile, isNull);
      expect(record.fuelEconomyScore, isNull);
      expect(record.greenhouseGasScore, isNull);
    });

    test('campos mal formados o negativos quedan nulos', () {
      final record = VehicleRecordMapper.toEntity(
        FuelEconomyVehicleModel.fromJson(const <String, dynamic>{
          'rangeA': 'abc',
          'range': '-5',
          'combE': '',
          'co2TailpipeGpm': '-3',
          'feScore': 'x',
          'ghgScore': null,
        }),
      );
      expect(record.electricRangeMiles, isNull);
      expect(record.totalRangeMiles, isNull);
      expect(record.electricConsumptionKwhPer100Miles, isNull);
      expect(record.co2GramsPerMile, isNull);
      expect(record.fuelEconomyScore, isNull);
      expect(record.greenhouseGasScore, isNull);
    });

    test('el CO₂ 0 se conserva y la puntuación -1 llega tal cual', () {
      final record = VehicleRecordMapper.toEntity(
        FuelEconomyVehicleModel.fromJson({...realTesla, 'feScore': '-1'}),
      );
      expect(record.co2GramsPerMile, 0);
      expect(record.fuelEconomyScore, -1);
    });

    test('acepta números reales además de texto', () {
      final record = VehicleRecordMapper.toEntity(
        FuelEconomyVehicleModel.fromJson(const <String, dynamic>{
          'range': 330,
          'feScore': 7,
        }),
      );
      expect(record.totalRangeMiles, 330);
      expect(record.fuelEconomyScore, 7);
    });
  });

  test('la versión de clave del detalle es v3', () {
    expect(VehicleSpecsConfig.vehicleDetailCacheKeyVersion, 'v3');
  });

  group('caché de Isar con los campos nuevos', () {
    late Directory directory;
    late Isar isar;
    late IsarVehicleDetailCacheDatasource datasource;

    setUpAll(() async {
      await IsarTestSupport.prepare();
    });

    setUp(() async {
      if (IsarTestSupport.skipIfUnavailable()) return;
      directory = await Directory.systemTemp.createTemp('isar_efficiency');
      isar = await Isar.open(
        [VehicleDetailCacheModelSchema],
        directory: directory.path,
        name: 'prueba',
        inspector: false,
      );
      datasource = IsarVehicleDetailCacheDatasource(isar);
    });

    tearDown(() async {
      if (IsarTestSupport.skipReason != null) return;
      await isar.close(deleteFromDisk: true);
      await directory.delete(recursive: true);
    });

    final savedAt = DateTime.fromMillisecondsSinceEpoch(1700000000000);

    CachedDetailEntity entity(VehicleDetailEntity detail) =>
        CachedDetailEntity(detail: detail, savedAt: savedAt);

    test('ida y vuelta con todos los campos nuevos', () async {
      if (IsarTestSupport.skipIfUnavailable()) return;
      final full = entity(
        const VehicleDetailEntity(
          id: 41489,
          year: 2020,
          make: 'Toyota',
          model: 'Prius Prime',
          vehicleClass: 'Midsize Cars',
          powertrain: Powertrain.pluginHybrid,
          transmission: null,
          cylinders: 4,
          displacementLiters: 1.8,
          drive: null,
          fuelType: null,
          cityKmPerLiter: null,
          highwayKmPerLiter: null,
          combinedKmPerLiter: null,
          annualFuelCostUsd: 1100,
          co2GramsPerKilometer: 48.5,
          electricRangeKilometers: 40.2,
          totalRangeKilometers: 1030.0,
          electricConsumptionKwhPer100Kilometers: 15.5,
          hybridGasKmPerLiter: 23.1,
          fuelScore: 10,
          emissionsScore: 9,
        ),
      );
      await datasource.write('v3|41489', full);
      expect(await datasource.read('v3|41489'), full);
    });

    test('ida y vuelta con los campos nuevos nulos y el CO₂ 0', () async {
      if (IsarTestSupport.skipIfUnavailable()) return;
      final empty = entity(
        const VehicleDetailEntity(
          id: 1,
          year: 2020,
          make: 'A',
          model: 'B',
          vehicleClass: null,
          powertrain: Powertrain.electric,
          transmission: null,
          cylinders: null,
          displacementLiters: null,
          drive: null,
          fuelType: null,
          cityKmPerLiter: null,
          highwayKmPerLiter: null,
          combinedKmPerLiter: null,
          annualFuelCostUsd: null,
        ),
      );
      await datasource.write('v3|1', empty);
      expect(await datasource.read('v3|1'), empty);
      final zero = entity(
        const VehicleDetailEntity(
          id: 2,
          year: 2020,
          make: 'A',
          model: 'B',
          vehicleClass: null,
          powertrain: Powertrain.electric,
          transmission: null,
          cylinders: null,
          displacementLiters: null,
          drive: null,
          fuelType: null,
          cityKmPerLiter: null,
          highwayKmPerLiter: null,
          combinedKmPerLiter: null,
          annualFuelCostUsd: null,
          co2GramsPerKilometer: 0,
        ),
      );
      await datasource.write('v3|2', zero);
      expect((await datasource.read('v3|2'))!.detail.co2GramsPerKilometer, 0);
    });
  });
}
