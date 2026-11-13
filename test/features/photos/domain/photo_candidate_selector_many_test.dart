import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/real_gallery_titles.dart';

PhotoCandidateEntity _candidate(String title, int rank) => PhotoCandidateEntity(
  title: title,
  thumbnailUrl: 'thumb-$rank',
  authorName: 'autor',
  licenseName: 'CC BY-SA 4.0',
  sourceUrl: 'fuente-$rank',
  rank: rank,
);

List<int> _ranksOf(Iterable<PhotoEntity> photos) => [
  for (final photo in photos) int.parse(photo.sourceUrl.split('-').last),
];

void main() {
  const selector = PhotoCandidateSelector();

  test('BMW 228: solo el 228 xDrive Gran Coupé es válido', () {
    final photos = selector.selectMany(
      candidatesFrom(bmw228Titles),
      'BMW',
      '228',
      2027,
      6,
    );
    expect(_ranksOf(photos), [2]);
    expect(photos.single.isReference, isTrue);
  });

  test('Corolla 2020: primero las del año por rank y luego referencias', () {
    final photos = selector.selectMany(
      candidatesFrom(corolla2020Titles),
      'Toyota',
      'Corolla',
      2020,
      30,
    );
    final sameYear = photos.where((photo) => !photo.isReference);
    expect(_ranksOf(sameYear), [
      1, 3, 4, 5, 6, 9, 10, 12, 14, 15, 16, 18, 24, 28, 29, 30, //
    ]);
    // Tras las del año: la de 2021 (diferencia 1) y luego las sin año.
    final references = _ranksOf(photos.where((photo) => photo.isReference));
    expect(references.first, 25);
    expect(references.skip(1), [2, 7, 8, 11, 13, 17, 19, 20, 21, 22]);
    // Las de 1997 y 2004 quedan fuera por lejanas.
    expect(_ranksOf(photos).toSet().intersection({23, 26, 27}), isEmpty);
  });

  test('respeta el límite', () {
    final candidates = candidatesFrom(corolla2020Titles);
    for (final limit in [0, 1, 3, 6]) {
      expect(
        selector.selectMany(candidates, 'Toyota', 'Corolla', 2020, limit),
        hasLength(limit),
      );
    }
    expect(
      _ranksOf(selector.selectMany(candidates, 'Toyota', 'Corolla', 2020, 6)),
      [1, 3, 4, 5, 6, 9],
    );
  });

  test('no repite fotos con la misma fuente', () {
    final first = _candidate('File:2020 Toyota Corolla LE.jpg', 1);
    final duplicate = PhotoCandidateEntity(
      title: 'File:2020 Toyota Corolla SE.jpg',
      thumbnailUrl: 'otra',
      authorName: 'autor',
      licenseName: 'CC BY-SA 4.0',
      sourceUrl: first.sourceUrl,
      rank: 2,
    );
    final photos = selector.selectMany(
      [first, duplicate],
      'Toyota',
      'Corolla',
      2020,
      6,
    );
    expect(photos, hasLength(1));
    expect(photos.single.thumbnailUrl, first.thumbnailUrl);
  });

  test('las referencias se ordenan por cercanía de año, rank y sin año', () {
    final photos = selector.selectMany(
      [
        _candidate('File:2022 Toyota Corolla SE.jpg', 1),
        _candidate('File:Toyota Corolla sin año.jpg', 2),
        _candidate('File:2018 Toyota Corolla SE.jpg', 3),
        _candidate('File:2019 Toyota Corolla SE.jpg', 4),
      ],
      'Toyota',
      'Corolla',
      2020,
      6,
    );
    expect(_ranksOf(photos), [4, 1, 3, 2]);
  });

  test('el primero de selectMany coincide siempre con select', () {
    final cases = [
      (corolla2020Titles, 'Toyota', 'Corolla', 2020),
      (corolla2020Titles, 'Toyota', 'Corolla', 2019),
      (corolla2020Titles, 'Toyota', 'Corolla', 2040),
      (bmw228Titles, 'BMW', '228', 2027),
      (bmw228Titles, 'BMW', '228', 2026),
      (bmw228Titles, 'Ford', 'F-150', 2020),
    ];
    for (final (titles, brand, model, year) in cases) {
      final candidates = candidatesFrom(titles);
      final many = selector.selectMany(candidates, brand, model, year, 6);
      final one = selector.select(candidates, brand, model, year);
      expect(many.isEmpty ? null : many.first, one, reason: '$model $year');
    }
  });
}
