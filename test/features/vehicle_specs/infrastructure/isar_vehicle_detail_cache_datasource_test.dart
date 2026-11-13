import 'dart:io';

import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../support/isar_test_support.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late IsarVehicleDetailCacheDatasource datasource;

  setUpAll(() async {
    await IsarTestSupport.prepare();
  });

  setUp(() async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    directory = await Directory.systemTemp.createTemp('isar_detail_cache');
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
  final full = CachedDetailEntity(
    detail: const VehicleDetailEntity(
      id: 41213,
      year: 2020,
      make: 'Toyota',
      model: 'Corolla',
      vehicleClass: 'Compact Cars',
      powertrain: Powertrain.combustion,
      transmission: 'Automatic (AV-S10)',
      cylinders: 4,
      displacementLiters: 2.0,
      drive: 'Front-Wheel Drive',
      fuelType: 'Regular',
      cityKmPerLiter: 13.18,
      highwayKmPerLiter: 17.0,
      combinedKmPerLiter: 14.57,
      annualFuelCostUsd: 1750,
    ),
    savedAt: savedAt,
  );

  test('una clave inexistente devuelve nulo', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    expect(await datasource.read('nada'), isNull);
  });

  test('ida y vuelta con todos los campos', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await datasource.write('v1|41213', full);
    expect(await datasource.read('v1|41213'), full);
  });

  test('ida y vuelta con los campos nulos', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    final empty = CachedDetailEntity(
      detail: const VehicleDetailEntity(
        id: 42274,
        year: 2020,
        make: 'Tesla',
        model: 'Model 3 Long Range',
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
      savedAt: savedAt,
    );
    await datasource.write('v1|42274', empty);
    expect(await datasource.read('v1|42274'), empty);
  });

  test('escribir una clave existente la reemplaza', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await datasource.write('v1|41213', full);
    final other = CachedDetailEntity(
      detail: const VehicleDetailEntity(
        id: 41213,
        year: 2020,
        make: 'Toyota',
        model: 'Corolla',
        vehicleClass: 'Midsize Cars',
        powertrain: Powertrain.combustion,
        transmission: null,
        cylinders: null,
        displacementLiters: null,
        drive: null,
        fuelType: null,
        cityKmPerLiter: null,
        highwayKmPerLiter: null,
        combinedKmPerLiter: null,
        annualFuelCostUsd: 900,
      ),
      savedAt: savedAt,
    );
    await datasource.write('v1|41213', other);
    expect(await datasource.read('v1|41213'), other);
    expect(await isar.vehicleDetailCacheModels.count(), 1);
  });
}
