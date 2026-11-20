import 'dart:io';

import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../support/isar_test_support.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late IsarGroupOptionsCacheDatasource datasource;

  setUpAll(() async {
    await IsarTestSupport.prepare();
  });

  setUp(() async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    directory = await Directory.systemTemp.createTemp('isar_options_cache');
    isar = await Isar.open(
      [GroupOptionsCacheModelSchema],
      directory: directory.path,
      name: 'prueba',
      inspector: false,
    );
    datasource = IsarGroupOptionsCacheDatasource(isar);
  });

  tearDown(() async {
    if (IsarTestSupport.skipReason != null) return;
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  test('una clave nunca guardada da nulo', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    expect(await datasource.read('x'), isNull);
  });

  test('guarda las versiones en orden y las lee iguales', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    const options = [
      VehicleOptionEntity(id: 7, text: 'Auto 4cyl'),
      VehicleOptionEntity(id: 2, text: 'Manual 6-spd'),
    ];
    await datasource.write('k', options);
    expect(await datasource.read('k'), options);
  });

  test('escribir la misma clave reemplaza la entrada', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    await datasource.write('k', const [VehicleOptionEntity(id: 1, text: 'a')]);
    await datasource.write('k', const [VehicleOptionEntity(id: 2, text: 'b')]);
    expect(await datasource.read('k'), const [
      VehicleOptionEntity(id: 2, text: 'b'),
    ]);
  });
}
