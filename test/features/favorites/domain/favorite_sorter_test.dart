import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/favorites_test_support.dart';

FavoriteEntity _fav(
  String model, {
  String brand = 'Toyota',
  int year = 2025,
  int minute = 0,
  double? maxKm,
}) => testFavorite(
  model: model,
  brand: brand,
  year: year,
  savedAt: DateTime(2026, 1, 1, 0, minute),
  snapshot: FavoriteSnapshotEntity(maxKmPerLiter: maxKm),
);

List<String> _names(List<FavoriteEntity> list) => [
  for (final favorite in list) '${favorite.brand} ${favorite.modelName}',
];

void main() {
  test('recientes: fecha descendente y desempate por nombre', () {
    final sorted = FavoriteSorter.sort([
      _fav('B', minute: 1),
      _fav('C', minute: 3),
      _fav('A', minute: 3),
    ], FavoriteSortMode.recent);
    expect(_names(sorted), ['Toyota A', 'Toyota C', 'Toyota B']);
  });

  test('A–Z: marca, modelo y año, sin importar acentos ni mayúsculas', () {
    final sorted = FavoriteSorter.sort([
      _fav('Yaris', brand: 'toyota', year: 2025),
      _fav('Camry', brand: 'Toyota', year: 2025),
      _fav('Camry', brand: 'Toyota', year: 2024),
      _fav('Á3', brand: 'Audi'),
    ], FavoriteSortMode.alphabetical);
    expect(_names(sorted), [
      'Audi Á3',
      'Toyota Camry',
      'Toyota Camry',
      'toyota Yaris',
    ]);
    expect(sorted[1].year, 2024);
  });

  test('más eficiente: mayor km/l máximo primero y los nulos al final', () {
    final sorted = FavoriteSorter.sort([
      _fav('Sin dato'),
      _fav('Medio', maxKm: 12),
      _fav('Alto', maxKm: 20),
      _fav('Otro sin dato', brand: 'Audi'),
    ], FavoriteSortMode.mostEfficient);
    expect(_names(sorted), [
      'Toyota Alto',
      'Toyota Medio',
      'Audi Otro sin dato',
      'Toyota Sin dato',
    ]);
  });

  test('con todo igual desempata por la clave y no toca la lista original', () {
    final first = _fav('Camry', minute: 1);
    final input = [first, _fav('Camry', brand: 'Toyota', minute: 1)];
    final sorted = FavoriteSorter.sort(input, FavoriteSortMode.alphabetical);
    expect(sorted.length, 2);
    expect(identical(sorted, input), isFalse);
    expect(input.first, first);
  });
}
