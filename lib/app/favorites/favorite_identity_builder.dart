import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// Arma la identidad de favorito desde lo que cada pantalla ya conoce del modelo.
class FavoriteIdentityBuilder {
  const FavoriteIdentityBuilder._();

  /// Clave del grupo: su nombre sin mayúsculas ni acentos (igual que en Comparar).
  static String groupKeyOf(String groupName) =>
      TextNormalizer.normalize(groupName);

  static FavoriteIdentity of({
    required String marketCode,
    required int year,
    required String brand,
    required String groupName,
  }) => FavoriteIdentity(
    marketCode: marketCode,
    year: year,
    brand: brand,
    groupKey: groupKeyOf(groupName),
    modelName: groupName,
  );

  /// De Detalle: el mercado y el año de sus argumentos, no los globales.
  static FavoriteIdentity fromDetail(DetailArgsEntity args) => of(
    marketCode: args.market.code,
    year: args.year,
    brand: args.brand,
    groupName: args.groupName,
  );

  /// De un resultado de búsqueda; nulo si es solo una marca.
  static FavoriteIdentity? fromResult(SearchResultEntity result) {
    final groupName = result.groupName;
    if (groupName == null) return null;
    return of(
      marketCode: result.marketCode,
      year: result.year,
      brand: result.brand,
      groupName: groupName,
    );
  }
}
