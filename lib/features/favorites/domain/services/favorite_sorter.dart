import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_entity.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_sort_mode.dart';

/// Ordena favoritos; todos los modos desempatan por nombre y luego por identidad.
class FavoriteSorter {
  const FavoriteSorter._();

  /// Copia ordenada según [mode]; la lista original no se toca.
  static List<FavoriteEntity> sort(
    List<FavoriteEntity> favorites,
    FavoriteSortMode mode,
  ) {
    final compare = switch (mode) {
      FavoriteSortMode.recent => _byRecent,
      FavoriteSortMode.alphabetical => _byName,
      FavoriteSortMode.mostEfficient => _byEfficiency,
    };
    return [...favorites]..sort(compare);
  }

  // Más reciente primero.
  static int _byRecent(FavoriteEntity a, FavoriteEntity b) {
    final byDate = b.savedAt.compareTo(a.savedAt);
    return byDate != 0 ? byDate : _tieBreak(a, b);
  }

  // Marca, modelo y año.
  static int _byName(FavoriteEntity a, FavoriteEntity b) => _tieBreak(a, b);

  // Mayor km/l máximo primero; sin dato al final.
  static int _byEfficiency(FavoriteEntity a, FavoriteEntity b) {
    final first = a.snapshot.maxKmPerLiter;
    final second = b.snapshot.maxKmPerLiter;
    if (first == null && second == null) return _tieBreak(a, b);
    if (first == null) return 1;
    if (second == null) return -1;
    final byValue = second.compareTo(first);
    return byValue != 0 ? byValue : _tieBreak(a, b);
  }

  // Nombre (marca, modelo, año) y, si empata, la clave de identidad.
  static int _tieBreak(FavoriteEntity a, FavoriteEntity b) {
    final byBrand = TextNormalizer.normalize(a.brand)
        .compareTo(TextNormalizer.normalize(b.brand));
    if (byBrand != 0) return byBrand;
    final byModel = TextNormalizer.normalize(a.modelName)
        .compareTo(TextNormalizer.normalize(b.modelName));
    if (byModel != 0) return byModel;
    final byYear = a.year.compareTo(b.year);
    return byYear != 0 ? byYear : a.key.compareTo(b.key);
  }
}
