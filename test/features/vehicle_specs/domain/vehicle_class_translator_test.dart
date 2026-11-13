import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/vehicle_class_fixture.dart';

void main() {
  const translator = VehicleClassTranslator();

  const expected = <String, String>{
    'Small Sport Utility Vehicle 2WD': 'SUV pequeña',
    'Standard Sport Utility Vehicle 4WD': 'SUV estándar',
    'Small Pickup Trucks 4WD': 'Pickup pequeña',
    'Standard Pickup Trucks/2wd': 'Pickup estándar',
    'Minivan - 2WD': 'Minivan',
    'Minivan - 4WD': 'Minivan',
    'Two Seaters': 'Dos plazas',
  };

  for (final entry in expected.entries) {
    test('traduce "${entry.key}" a "${entry.value}"', () {
      expect(translator.labelFor(entry.key), entry.value);
    });
  }

  test('una clase no observada se devuelve sin sufijo y en inglés', () {
    expect(translator.labelFor('Hovercraft Class 2WD'), 'Hovercraft Class');
  });

  test('cada valor real de VClass se traduce con texto corto', () {
    for (final entry in realVehicleClassTranslations.entries) {
      final label = translator.labelFor(entry.key);
      expect(label, entry.value, reason: entry.key);
      expect(label, isNotEmpty, reason: entry.key);
      expect(label!.length, lessThanOrEqualTo(24), reason: entry.key);
    }
  });

  test('toda traducción de la tabla es corta y no vacía', () {
    for (final entry in VehicleClassTexts.labels.entries) {
      expect(entry.value, isNotEmpty, reason: entry.key);
      expect(entry.value.length, lessThanOrEqualTo(24), reason: entry.key);
    }
  });

  test('un valor sin entrada llama a la función con el valor limpio', () {
    final calls = <String>[];
    final logging = VehicleClassTranslator(onUntranslated: calls.add);
    expect(logging.labelFor('Hovercraft Class 4WD'), 'Hovercraft Class');
    expect(logging.labelFor('Compact Cars'), 'Compacto');
    expect(calls, ['Hovercraft Class']);
  });

  test('sin función un valor sin entrada no falla', () {
    expect(translator.labelFor('Hovercraft Class'), 'Hovercraft Class');
  });

  test('el sufijo se quita sin distinguir mayúsculas', () {
    expect(translator.labelFor('Small Pickup Trucks 4wd'), 'Pickup pequeña');
  });

  test('nulo y vacío devuelven nulo', () {
    expect(translator.labelFor(null), isNull);
    expect(translator.labelFor(''), isNull);
    expect(translator.labelFor('   '), isNull);
  });
}
