import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/nhtsa_fixtures.dart';

void main() {
  const matcher = NhtsaModelMatcher();

  group('NhtsaModelMatcher', () {
    test('Camry empareja exacto y no arrastra el híbrido', () {
      expect(matcher.match('Toyota', 'Camry', toyota2024Models), ['CAMRY']);
    });

    test('Corolla empareja exacto y no arrastra Cross ni GR', () {
      expect(matcher.match('Toyota', 'Corolla', toyota2024Models), ['COROLLA']);
    });

    test('ignora mayúsculas, espacios y guiones', () {
      expect(matcher.match('Tesla', 'Model 3', tesla2024Models), ['MODEL 3']);
      expect(matcher.match('Tesla', 'model-3', tesla2024Models), ['MODEL 3']);
    });

    test('prefijo ambiguo queda sin emparejar (Silverado)', () {
      expect(
        matcher.match('Chevrolet', 'Silverado', chevrolet2024Models),
        isEmpty,
      );
    });

    test('un nombre parcial no se empareja por prefijo', () {
      expect(matcher.match('Honda', 'Civ', honda2024Models), isEmpty);
    });

    test('alias: Civic reúne sedán y hatchback, no Si ni Type R', () {
      expect(matcher.match('Honda', 'Civic', honda2024Models), [
        'CIVIC HATCHBACK',
        'CIVIC SEDAN',
      ]);
    });

    test('alias: F-150 reúne las cabinas de gasolina e híbrida', () {
      expect(matcher.match('Ford', 'F-150', ford2024Models), [
        'F-150 (REGULAR CAB) GAS',
        'F-150 (SUPER CAB) GAS',
        'F-150 (SUPER CREW) GAS',
        'F-150 (SUPER CREW) HEV',
      ]);
    });

    test('alias: Model Y apunta a "All Variants", no a RWD', () {
      expect(matcher.match('Tesla', 'Model Y', tesla2024Models), [
        'MODEL Y (All Variants)',
      ]);
    });

    test('alias: GTI y GLI apuntan al nombre de familia de NHTSA', () {
      expect(matcher.match('Volkswagen', 'GTI', volkswagen2024Models), [
        'GOLF GTI',
      ]);
      expect(matcher.match('Volkswagen', 'GLI', volkswagen2024Models), [
        'JETTA GLI',
      ]);
    });

    test('alias: BMW i4, M3 y M2 apuntan a su carrocería única', () {
      expect(matcher.match('BMW', 'i4', bmw2024Models), ['I4 GRAN COUPE']);
      expect(matcher.match('BMW', 'M3', bmw2024Models), ['M3 SEDAN']);
      expect(matcher.match('BMW', 'M2', bmw2024Models), ['M2 COUPE']);
    });

    test('alias: híbridos únicos de Toyota y Ranger SuperCrew', () {
      expect(matcher.match('Toyota', 'Sienna', toyotaHybrid2024Models), [
        'SIENNA HYBRID',
      ]);
      expect(matcher.match('Toyota', 'Crown', toyotaHybrid2024Models), [
        'CROWN HYBRID',
      ]);
      expect(matcher.match('Ford', 'Ranger', fordRanger2024Models), [
        'RANGER (SUPER CREW)',
      ]);
    });

    test('ambiguo sin alias: BMW M4 (cupé y convertible) no se empareja', () {
      expect(matcher.match('BMW', 'M4', bmw2024Models), isEmpty);
    });

    test('sin alias: Audi A8 y S8 no se emparejan con la versión LWB', () {
      const audiModels = ['A8 LWB', 'S8 LWB'];
      expect(matcher.match('Audi', 'A8', audiModels), isEmpty);
      expect(matcher.match('Audi', 'S8', audiModels), isEmpty);
    });

    test('el alias no aplica si NHTSA no lista ese nombre', () {
      expect(matcher.match('Honda', 'Civic', toyota2024Models), isEmpty);
    });

    test('la tabla de alias es inyectable', () {
      const custom = NhtsaModelMatcher(
        aliases: {
          'toyota|camry': ['COROLLA'],
        },
      );
      expect(custom.match('Toyota', 'Camry', ['COROLLA']), ['COROLLA']);
    });
  });

  group('RecallDateParser', () {
    const parser = RecallDateParser();

    test('lee dd/MM/yyyy', () {
      expect(parser.parse('22/02/2024'), DateTime.utc(2024, 2, 22));
      expect(parser.parse('02/05/2025'), DateTime.utc(2025, 5, 2));
    });

    test('formato distinto o fecha imposible es nulo', () {
      expect(parser.parse(null), isNull);
      expect(parser.parse(''), isNull);
      expect(parser.parse('2024-02-22'), isNull);
      expect(parser.parse('31/02/2024'), isNull);
      expect(parser.parse('2/5/2025'), isNull);
    });
  });

  group('GroupSafetyBuilder', () {
    const builder = GroupSafetyBuilder();

    test('BMW X5: una versión calificada y otra sin general', () {
      final group = builder.build(const [
        SafetyRatingEntity(overall: 4, front: 4, side: 5, rollover: 4),
        SafetyRatingEntity(front: 4, side: 5),
      ]);
      expect(group.ratedCount, 1);
      expect(group.minOverall, 4);
      expect(group.maxOverall, 4);
    });

    test('rango mínimo y máximo con varias versiones', () {
      final group = builder.build(const [
        SafetyRatingEntity(overall: 5),
        SafetyRatingEntity(overall: 3),
        SafetyRatingEntity(overall: 4),
      ]);
      expect(
        group,
        const GroupSafetyEntity(ratedCount: 3, minOverall: 3, maxOverall: 5),
      );
    });

    test('todo sin calificar: cuenta 0 y rango nulo, nunca 0 estrellas', () {
      final group = builder.build(const [SafetyRatingEntity()]);
      expect(group.ratedCount, 0);
      expect(group.minOverall, isNull);
      expect(group.maxOverall, isNull);
    });
  });

  test('SafetyKeyBuilder versiona y normaliza la clave', () {
    expect(
      const SafetyKeyBuilder().build('ratings', 2024, 'Mercedes-Benz', 'C 300'),
      'v2|ratings|2024|mercedesbenz|c300',
    );
  });
}
