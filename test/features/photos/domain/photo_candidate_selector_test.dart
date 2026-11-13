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

  group('regla de posición y años', () {
    final bmwTitles = [
      'File:Plang nama Stasiun Bumiwaluya.jpg',
      'File:BMW 228 xDrive Gran Coupé (F74, 2026) (55256563627).jpg',
      'File:BMW Isetta in VEER MALL (Yekaterinburg, Russia), 2022 02.jpg',
      'File:BMW Alpina XB7.jpg',
      'File:BMW 535i F10 (5227267038).jpg',
      'File:BMW 550i F10 (5226669841).jpg',
      'File:Bmw-fahrrad-2006.jpg',
      'File:1974 BMW E9 3.0 CSA Auto.jpg',
      'File:2023-02-11 BMW IBU World Championships Biathlon Oberhof 2023 – Men 10 km Sprint by Sandro Halank–228.jpg',
      'File:2023-02-14 BMW IBU World Championships Biathlon Oberhof 2023 – Men 20 km Individual by Sandro Halank–228.jpg',
      'File:2023-02-15 BMW IBU World Championships Biathlon Oberhof 2023 – Women 15 km Individual by Sandro Halank–228.jpg',
      'File:11-09-04-iaa-by-RalfR-228.jpg',
      'File:2023-02-10 BMW IBU World Championships Biathlon Oberhof 2023 – Women 7.5 km Sprint by Sandro Halank–228.jpg',
      'File:BMW M5 - Flickr - The Car Spy (18).jpg',
      'File:Renovation Works in Bumiwaluya Station.jpg',
      'File:BMW2022.jpeg',
      'File:Stasiun Bumiwaluya 2020.jpg',
      'File:KA Mutiara Selatan Bumiwaluya.jpg',
      'File:KITLV A686 - Station Malangbong van de Staatsspoorwegen bij Garoet, KITLV 54433.tiff',
      'File:325ix Touring.jpg',
    ];
    // Candidatos con rank igual a su posición (empieza en 1).
    List<PhotoCandidateEntity> bmwCandidates() => [
      for (final entry in bmwTitles.asMap().entries)
        _candidate(entry.value, entry.key + 1),
    ];

    PhotoEntity? pick(String brand, String model, int year, String title) =>
        selector.select([_candidate('File:$title', 1)], brand, model, year);

    test('BMW 228 2027 elige el candidato 2 como referencia', () {
      final photo = selector.select(bmwCandidates(), 'BMW', '228', 2027);
      expect(photo?.sourceUrl, 'fuente-2');
      expect(photo?.isReference, isTrue);
    });

    test('BMW 228 2026 elige el candidato 2 con año coincidente', () {
      final photo = selector.select(bmwCandidates(), 'BMW', '228', 2026);
      expect(photo?.sourceUrl, 'fuente-2');
      expect(photo?.isReference, isFalse);
    });

    test('los candidatos 9, 10, 11, 12 y 13 se rechazan solos', () {
      final candidates = bmwCandidates();
      for (final position in [9, 10, 11, 12, 13]) {
        final photo = selector.select(
          [candidates[position - 1]],
          'BMW',
          '228',
          2027,
        );
        expect(photo, isNull, reason: 'candidato $position');
      }
    });

    test('un año con forma de fecha no es año inicial', () {
      final photo = pick(
        'BMW',
        'IBU',
        2023,
        '2023-02-11 BMW IBU World Championships.jpg',
      );
      expect(photo?.isReference, isTrue);
    });

    test('Corolla LE se elige y Corolla Cross se excluye', () {
      expect(
        pick(
          'Toyota',
          'Corolla',
          2020,
          '2020 Toyota Corolla LE 12-13-2019.jpg',
        )?.isReference,
        isFalse,
      );
      expect(
        pick(
          'Toyota',
          'Corolla',
          2020,
          '2020 Toyota Corolla Cross - Front.jpg',
        ),
        isNull,
      );
    });

    test('BMW 330i con la clave tras tres palabras y año entre paréntesis', () {
      final photo = pick(
        'BMW',
        '330i',
        2020,
        'BMW 3-Series (G20) 330i (2020) (52184513944).jpg',
      );
      expect(photo?.isReference, isFalse);
    });

    test('BMW X3 2019 es referencia para 2020', () {
      final photo = pick('BMW', 'X3', 2020, '2019 BMW X3 xDrive30i front.jpg');
      expect(photo?.isReference, isTrue);
    });

    test('Honda CR-V coincide con las palabras CR y V', () {
      final photo = pick(
        'Honda',
        'CR-V',
        2020,
        '2020 Honda CR-V EX i-MMD CVT 2.0.jpg',
      );
      expect(photo?.isReference, isFalse);
    });

    test('Ford F150 descarta 2008 y no cuenta el 2020 del final', () {
      final photo = pick(
        'Ford',
        'F150',
        2020,
        '2008 Ford F150, Front Left, 10-02-2020.jpg',
      );
      expect(photo, isNull);
    });

    test('Mercedes-Benz se reconoce como dos palabras unidas', () {
      final photo = pick(
        'Mercedes-Benz',
        'C300',
        2020,
        '2020 Mercedes-Benz C300 AMG Line Night Edition Premium 2.0 Front.jpg',
      );
      expect(photo?.isReference, isFalse);
    });

    test('Aston Martin DBX sin año es referencia', () {
      final photo = pick(
        'Aston Martin',
        'DBX',
        2027,
        'Aston Martin DBX DSC 7244.jpg',
      );
      expect(photo?.isReference, isTrue);
    });

    test('Kia Sportage y Toyota 86 coinciden con su año', () {
      expect(
        pick(
          'Kia',
          'Sportage',
          2020,
          '2020 Kia Sportage au SIAM 2020.png',
        )?.isReference,
        isFalse,
      );
      expect(
        pick('Toyota', '86', 2020, '2020 Toyota 86 Hakone.jpg')?.isReference,
        isFalse,
      );
    });

    test('la clave 228 coincide con 228i pero no con 2288', () {
      expect(pick('BMW', '228', 2027, 'BMW 228i Coupe.jpg'), isNotNull);
      expect(pick('BMW', '228', 2027, 'BMW 2288 Coupe.jpg'), isNull);
    });

    test('el modelo antes de la marca no es válido', () {
      expect(pick('BMW', '228', 2027, '228 BMW Coupe.jpg'), isNull);
    });

    test('el modelo a 4 palabras de la marca es válido y a 5 no', () {
      expect(
        pick('BMW', '228', 2027, 'BMW uno dos tres cuatro 228.jpg'),
        isNotNull,
      );
      expect(
        pick('BMW', '228', 2027, 'BMW uno dos tres cuatro cinco 228.jpg'),
        isNull,
      );
    });

    test('una segunda aparición de la marca puede traer el modelo', () {
      final photo = pick(
        'BMW',
        '228',
        2027,
        'BMW uno dos tres cuatro cinco BMW 228.jpg',
      );
      expect(photo, isNotNull);
    });
  });
}
