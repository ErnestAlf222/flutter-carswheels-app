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

  test('la tabla de clases no trae sufijos de tracción', () {
    final suffix = RegExp(
      VehicleSpecsConfig.driveSuffixPattern,
      caseSensitive: false,
    );
    for (final key in VehicleSpecsConfig.vehicleClassLabels.keys) {
      expect(suffix.hasMatch(key), isFalse, reason: key);
    }
  });

  test('las pickups estándar tienen traducción sin tracción', () {
    expect(
      VehicleSpecsConfig.vehicleClassLabels['Standard Pickup Trucks'],
      'Pickup estándar',
    );
    expect(
      VehicleSpecsConfig.vehicleClassLabels['Standard Pickup'],
      'Pickup estándar',
    );
  });

  test('el patrón de tracción reconoce 2WD y 4WD con o sin guion', () {
    final suffix = RegExp(
      VehicleSpecsConfig.driveSuffixPattern,
      caseSensitive: false,
    );
    expect(suffix.hasMatch('Minivan - 2WD'), isTrue);
    expect(suffix.hasMatch('Small SUV 4WD'), isTrue);
    expect(suffix.hasMatch('Compact Cars'), isFalse);
  });

  test('la versión de la clave del resumen es v2', () {
    expect(VehicleSpecsConfig.summaryCacheKeyVersion, 'v2');
  });
}
