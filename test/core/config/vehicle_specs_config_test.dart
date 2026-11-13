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
}
