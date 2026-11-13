import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/real_fuel_economy_values.dart';

void main() {
  group('LabelTableTranslator', () {
    test('nulo o vacío da nulo y no avisa', () {
      final reported = <String>[];
      final translator = LabelTableTranslator(
        table: const {'a': 'A'},
        onUntranslated: reported.add,
      );
      expect(translator.labelFor(null), isNull);
      expect(translator.labelFor(''), isNull);
      expect(translator.labelFor('  '), isNull);
      expect(reported, isEmpty);
    });

    test('con entrada traduce; sin entrada devuelve tal cual y avisa', () {
      final reported = <String>[];
      final translator = LabelTableTranslator(
        table: const {'a': 'A'},
        onUntranslated: reported.add,
      );
      expect(translator.labelFor('a'), 'A');
      expect(reported, isEmpty);
      expect(translator.labelFor('zzz'), 'zzz');
      expect(reported, ['zzz']);
    });

    test('sin función de aviso no falla', () {
      const translator = LabelTableTranslator(table: {});
      expect(translator.labelFor('x'), 'x');
    });
  });

  group('DriveLabeler', () {
    const labeler = DriveLabeler();

    test('traduce los ejemplos', () {
      expect(labeler.labelFor('Front-Wheel Drive'), 'Tracción delantera');
      expect(labeler.labelFor('Rear-Wheel Drive'), 'Tracción trasera');
      expect(labeler.labelFor('All-Wheel Drive'), 'Tracción integral');
      expect(labeler.labelFor('4-Wheel or All-Wheel Drive'), '4x4 o integral');
      expect(labeler.labelFor('4-Wheel Drive'), '4x4');
      expect(labeler.labelFor('Part-time 4-Wheel Drive'), '4x4 parcial');
      expect(labeler.labelFor('2-Wheel Drive'), 'Tracción en 2 ruedas');
    });

    test('con todos los valores reales: vacío es nulo y el resto traduce', () {
      final reported = <String>[];
      final real = DriveLabeler(onUntranslated: reported.add);
      for (final value in realDriveValues) {
        final label = real.labelFor(value);
        if (value.isEmpty) {
          expect(label, isNull);
        } else {
          expect(label, isNot(value), reason: value);
        }
      }
      expect(reported, isEmpty);
    });
  });

  group('FuelTypeLabeler', () {
    test('traduce los ejemplos', () {
      const labeler = FuelTypeLabeler();
      expect(labeler.labelFor('Regular'), 'Gasolina regular');
      expect(labeler.labelFor('Diesel'), 'Diésel');
      expect(labeler.labelFor('Gasoline or E85'), 'Gasolina o E85');
      expect(labeler.labelFor('Hydrogen'), 'Hidrógeno');
    });

    test('con todos los valores reales nada queda sin traducir', () {
      final reported = <String>[];
      final labeler = FuelTypeLabeler(onUntranslated: reported.add);
      for (final value in realFuelTypeValues) {
        final label = labeler.labelFor(value);
        if (value.isEmpty) {
          expect(label, isNull);
        } else {
          expect(label, isNot(value), reason: value);
        }
      }
      expect(reported, isEmpty);
    });

    test('un valor nuevo se devuelve tal cual y avisa', () {
      final reported = <String>[];
      final labeler = FuelTypeLabeler(onUntranslated: reported.add);
      expect(labeler.labelFor('Plutonium'), 'Plutonium');
      expect(reported, ['Plutonium']);
    });
  });

  group('TransmissionLabeler', () {
    const labeler = TransmissionLabeler();

    const examples = <String, String>{
      'Automatic (AV-S10)': 'Automática CVT 10 vel.',
      'Automatic (variable gear ratios)': 'Automática CVT',
      'Automatic (S8)': 'Automática 8 vel.',
      'Automatic 4-spd': 'Automática 4 vel.',
      'Manual 6-spd': 'Manual 6 vel.',
      'Automatic (A1)': 'Automática 1 vel.',
      'Automatic (L4)': 'Automática 4 vel.',
      'Automatic (AM-S7)': 'Automática 7 vel.',
      'Automatic (AM7)': 'Automática 7 vel.',
      'Manual 4-spd Doubled': 'Manual 4 vel.',
    };

    for (final entry in examples.entries) {
      test('"${entry.key}" → "${entry.value}"', () {
        expect(labeler.labelFor(entry.key), entry.value);
      });
    }

    test('nulo o vacío da nulo', () {
      expect(labeler.labelFor(null), isNull);
      expect(labeler.labelFor(''), isNull);
    });

    test('un valor que no es manual ni automático se devuelve y avisa', () {
      final reported = <String>[];
      final custom = TransmissionLabeler(onUntranslated: reported.add);
      expect(custom.labelFor('Direct drive'), 'Direct drive');
      expect(reported, ['Direct drive']);
    });

    test('con TODOS los valores reales de trany: ninguno falla ni queda sin reconocer', () {
      final reported = <String>[];
      final real = TransmissionLabeler(onUntranslated: reported.add);
      final withoutSpeeds = <String>[];
      for (final value in realTransmissionValues) {
        final label = real.labelFor(value);
        if (value.isEmpty) {
          expect(label, isNull);
          continue;
        }
        expect(label, isNotNull, reason: value);
        expect(
          label!.startsWith('Automática') || label.startsWith('Manual'),
          isTrue,
          reason: value,
        );
        if (!label.contains('vel.')) withoutSpeeds.add(value);
      }
      expect(reported, isEmpty, reason: 'sin reconocer: $reported');
      // Solo la CVT sin cantidad de velocidades queda sin "vel.".
      expect(withoutSpeeds, ['Automatic (variable gear ratios)']);
    });
  });
}
