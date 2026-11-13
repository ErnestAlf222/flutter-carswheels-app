import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const translator = VehicleClassTranslator();

  const expected = <String, String>{
    'Minicompact Cars': 'Minicompacto',
    'Subcompact Cars': 'Subcompacto',
    'Compact Cars': 'Compacto',
    'Midsize Cars': 'Mediano',
    'Large Cars': 'Grande',
    'Two Seaters': 'Dos plazas',
    'Small Station Wagons': 'Familiar pequeña',
    'Midsize Station Wagons': 'Familiar mediana',
    'Small SUV 2WD': 'SUV pequeña',
    'Small SUV 4WD': 'SUV pequeña',
    'Standard SUV 2WD': 'SUV estándar',
    'Standard SUV 4WD': 'SUV estándar',
    'Small Pickup Trucks 2WD': 'Pickup pequeña',
    'Small Pickup Trucks 4WD': 'Pickup pequeña',
    'Small Pickup 2WD': 'Pickup pequeña',
    'Standard Pickup Trucks 2WD': 'Pickup estándar',
    'Standard Pickup Trucks 4WD': 'Pickup estándar',
    'Standard Pickup 2WD': 'Pickup estándar',
    'Standard Pickup 4WD': 'Pickup estándar',
    'Minivan - 2WD': 'Minivan',
    'Minivan - 4WD': 'Minivan',
  };

  for (final entry in expected.entries) {
    test('traduce "${entry.key}" a "${entry.value}"', () {
      expect(translator.labelFor(entry.key), entry.value);
    });
  }

  test('una clase no observada se devuelve sin sufijo y en inglés', () {
    expect(
      translator.labelFor('Special Purpose Vehicle 2WD'),
      'Special Purpose Vehicle',
    );
  });

  test('el sufijo se quita sin distinguir mayúsculas', () {
    expect(translator.labelFor('Small SUV 4wd'), 'SUV pequeña');
  });

  test('nulo y vacío devuelven nulo', () {
    expect(translator.labelFor(null), isNull);
    expect(translator.labelFor(''), isNull);
    expect(translator.labelFor('   '), isNull);
  });
}
