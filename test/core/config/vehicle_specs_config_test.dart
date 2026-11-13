import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la plantilla de ruta contiene el marcador de id', () {
    expect(
      VehicleSpecsConfig.vehiclePathTemplate,
      contains(VehicleSpecsConfig.idPlaceholder),
    );
  });

  test('las claves de la tabla de motorización están en minúsculas', () {
    for (final key in VehicleSpecsConfig.powertrainByAtvType.keys) {
      expect(key, key.toLowerCase());
    }
  });

  test('el patrón de tracción reconoce 2WD y 4WD con o sin guion', () {
    final suffix = RegExp(
      VehicleSpecsConfig.driveSuffixPattern,
      caseSensitive: false,
    );
    expect(suffix.hasMatch('Minivan - 2WD'), isTrue);
    expect(suffix.hasMatch('Small SUV 4WD'), isTrue);
    expect(suffix.hasMatch('Standard Pickup Trucks/2wd'), isTrue);
    expect(suffix.hasMatch('Compact Cars'), isFalse);
  });

  test('la versión de la clave del resumen es v3', () {
    expect(VehicleSpecsConfig.summaryCacheKeyVersion, 'v3');
  });

  test('FCV se clasifica como celda de combustible', () {
    expect(VehicleSpecsConfig.powertrainByAtvType['fcv'], 'fuelCell');
  });

  test('eFCV (CR-V e-FCEV) se clasifica como celda de combustible', () {
    expect(VehicleSpecsConfig.powertrainByAtvType['efcv'], 'fuelCell');
  });

  test('las claves del detalle y su vigencia están definidas', () {
    expect(VehicleSpecsConfig.annualFuelCostKey, 'fuelCost08');
    expect(VehicleSpecsConfig.displacementKey, 'displ');
    expect(VehicleSpecsConfig.transmissionKey, 'trany');
    expect(VehicleSpecsConfig.vehicleDetailCacheKeyVersion, 'v3');
    expect(VehicleSpecsConfig.vehicleDetailCacheTimeToLiveDays, 30);
  });

  test('la tabla de clases no trae sufijos de tracción', () {
    final suffix = RegExp(
      VehicleSpecsConfig.driveSuffixPattern,
      caseSensitive: false,
    );
    for (final key in VehicleClassTexts.labels.keys) {
      expect(suffix.hasMatch(key), isFalse, reason: key);
    }
  });
}
