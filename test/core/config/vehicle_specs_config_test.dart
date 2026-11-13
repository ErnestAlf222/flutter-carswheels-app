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

  test('las etiquetas de clase no están vacías', () {
    for (final label in VehicleSpecsConfig.vehicleClassLabels.values) {
      expect(label, isNotEmpty);
    }
  });

  test('las pickups estándar tienen traducción', () {
    expect(
      VehicleSpecsConfig.vehicleClassLabels['Standard Pickup Trucks 2WD'],
      'Pickup estándar 2WD',
    );
    expect(
      VehicleSpecsConfig.vehicleClassLabels['Standard Pickup Trucks 4WD'],
      'Pickup estándar 4WD',
    );
  });

  test('la versión de la clave del resumen es v2', () {
    expect(VehicleSpecsConfig.summaryCacheKeyVersion, 'v2');
  });
}
