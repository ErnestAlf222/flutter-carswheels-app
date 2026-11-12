import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

PhotoCandidateEntity _candidate(String title, int rank) => PhotoCandidateEntity(
  title: title,
  thumbnailUrl: 'thumb-$rank',
  authorName: 'autor',
  licenseName: 'CC BY-SA 4.0',
  sourceUrl: 'fuente-$rank',
  rank: rank,
);

void main() {
  const selector = PhotoCandidateSelector();

  group('cleanModelName', () {
    test('quita siglas de tracción y puertas sin importar mayúsculas', () {
      expect(selector.cleanModelName('Silverado 4WD'), 'Silverado');
      expect(selector.cleanModelName('Civic 4dr'), 'Civic');
      expect(selector.cleanModelName('F150 Pickup 2WD'), 'F150 Pickup');
    });

    test('quita espacios sobrantes', () {
      expect(
        selector.cleanModelName('  Corolla   Hatchback '),
        'Corolla Hatchback',
      );
    });
  });

  group('select', () {
    test('excluye Corolla Cross aunque sea el primero', () {
      final photo = selector.select(
        [
          _candidate('File:2020 Toyota Corolla Cross - Front.jpg', 1),
          _candidate('File:2020 Toyota Corolla LE 12-13-2019.jpg', 2),
        ],
        'Toyota',
        'Corolla',
        2020,
      );
      expect(photo?.sourceUrl, 'fuente-2');
      expect(photo?.isReference, isFalse);
    });

    test('el paréntesis con el año coincide con el año', () {
      final photo = selector.select(
        [
          _candidate(
            'File:BMW 3-Series (G20) 330 e (2020) (53334255255).jpg',
            1,
          ),
        ],
        'BMW',
        '3-Series',
        2020,
      );
      expect(photo?.isReference, isFalse);
    });

    test('un año suelto en medio del título no coincide', () {
      final photo = selector.select(
        [
          _candidate(
            'File:Dodge Charger (2015) Sindelfingen 2020 IMG 2399.jpg',
            1,
          ),
        ],
        'Dodge',
        'Charger',
        2020,
      );
      expect(photo, isNotNull);
      expect(photo?.isReference, isTrue);
    });

    test('excluye títulos con PHV', () {
      final photo = selector.select(
        [_candidate('File:2021 Toyota RAV4 PHV.jpg', 1)],
        'Toyota',
        'RAV4',
        2021,
      );
      expect(photo, isNull);
    });

    test('funciona con modelos con guion como CR-V', () {
      final photo = selector.select(
        [_candidate('File:2020 Honda CR-V EX i-MMD CVT 2.0.jpg', 1)],
        'Honda',
        'CR-V',
        2020,
      );
      expect(photo?.isReference, isFalse);
    });

    test('limpia el modelo antes de buscar la clave', () {
      final photo = selector.select(
        [_candidate('File:2020 Chevrolet Silverado LT.jpg', 1)],
        'Chevrolet',
        'Silverado 4WD',
        2020,
      );
      expect(photo?.isReference, isFalse);
    });

    test('sin candidatos válidos devuelve null', () {
      final photo = selector.select(
        [_candidate('File:Toyota Frontlander IMG001.jpg', 1)],
        'Toyota',
        'Corolla',
        2020,
      );
      expect(photo, isNull);
    });

    test('la clave del modelo ignora acentos y guiones', () {
      final photo = selector.select(
        [_candidate('File:2020 Citroen C-Élysée front.jpg', 1)],
        'Citroën',
        'C-Elysée',
        2020,
      );
      expect(photo, isNotNull);
    });

    test('prefiere el año aunque tenga peor rank que otro año', () {
      final photo = selector.select(
        [
          _candidate('File:2018 Toyota Corolla SE.jpg', 1),
          _candidate('File:2020 Toyota Corolla LE.jpg', 9),
        ],
        'Toyota',
        'Corolla',
        2020,
      );
      expect(photo?.sourceUrl, 'fuente-9');
      expect(photo?.isReference, isFalse);
    });

    test('sin año coincidente elige el de menor rank como referencia', () {
      final photo = selector.select(
        [
          _candidate('File:2022 Toyota Corolla SE.jpg', 5),
          _candidate('File:2018 Toyota Corolla SE.jpg', 2),
        ],
        'Toyota',
        'Corolla',
        2020,
      );
      expect(photo?.sourceUrl, 'fuente-2');
      expect(photo?.isReference, isTrue);
    });

    test('un candidato sin licencia se ignora', () {
      const unlicensed = PhotoCandidateEntity(
        title: 'File:2020 Toyota Corolla LE.jpg',
        thumbnailUrl: 'thumb',
        authorName: '',
        licenseName: '',
        sourceUrl: 'sin-licencia',
        rank: 1,
      );
      final photo = selector.select(
        [unlicensed, _candidate('File:2020 Toyota Corolla SE.jpg', 7)],
        'Toyota',
        'Corolla',
        2020,
      );
      expect(photo?.sourceUrl, 'fuente-7');
    });

    test('el autor vacío sí es válido', () {
      const anonymous = PhotoCandidateEntity(
        title: 'File:2020 Toyota Corolla LE.jpg',
        thumbnailUrl: 'thumb',
        authorName: '',
        licenseName: 'CC0',
        sourceUrl: 'anonima',
        rank: 1,
      );
      expect(
        selector.select([anonymous], 'Toyota', 'Corolla', 2020)?.sourceUrl,
        'anonima',
      );
    });

    test('descarta la referencia con 12 años de diferencia', () {
      final photo = selector.select(
        [_candidate('File:2008 Ford F150, Front Left, 10-02-2020.jpg', 1)],
        'Ford',
        'F150 Pickup 2WD',
        2020,
      );
      expect(photo, isNull);
    });

    test('elige como referencia un año cercano', () {
      final photo = selector.select(
        [_candidate('File:2019 BMW X3 xDrive30i front.jpg', 1)],
        'BMW',
        'X3',
        2020,
      );
      expect(photo?.isReference, isTrue);
    });

    test('entre 2018 y 2022 para 2020 gana el menor rank del empate', () {
      final photo = selector.select(
        [
          _candidate('File:2022 Toyota Corolla SE.jpg', 4),
          _candidate('File:2018 Toyota Corolla SE.jpg', 3),
        ],
        'Toyota',
        'Corolla',
        2020,
      );
      expect(photo?.sourceUrl, 'fuente-3');
    });

    test('gana la menor diferencia sobre el menor rank', () {
      final photo = selector.select(
        [
          _candidate('File:2017 Toyota Corolla SE.jpg', 1),
          _candidate('File:2019 Toyota Corolla SE.jpg', 9),
        ],
        'Toyota',
        'Corolla',
        2020,
      );
      expect(photo?.sourceUrl, 'fuente-9');
    });

    test('sin año al inicio es referencia, tras los de año cercano', () {
      final undated = _candidate('File:Aston Martin DBX DSC 7244.jpg', 1);
      final dated = _candidate('File:2024 Aston Martin DBX front.jpg', 8);
      final both = selector.select(
        [undated, dated],
        'Aston Martin',
        'DBX',
        2027,
      );
      expect(both?.sourceUrl, 'fuente-8');
      final alone = selector.select([undated], 'Aston Martin', 'DBX', 2027);
      expect(alone?.sourceUrl, 'fuente-1');
      expect(alone?.isReference, isTrue);
    });

    test('un año lejano se descarta aunque haya uno sin año', () {
      final photo = selector.select(
        [
          _candidate('File:2008 Aston Martin DBX front.jpg', 1),
          _candidate('File:Aston Martin DBX DSC 7244.jpg', 6),
        ],
        'Aston Martin',
        'DBX',
        2027,
      );
      expect(photo?.sourceUrl, 'fuente-6');
    });

    test('el año seguido de un dígito no coincide', () {
      final photo = selector.select(
        [_candidate('File:20201 Toyota Corolla.jpg', 1)],
        'Toyota',
        'Corolla',
        2020,
      );
      expect(photo?.isReference, isTrue);
    });
  });
}
