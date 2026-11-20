import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/config/favorites_config.dart';

/// Qué modelo es un favorito: mercado, año, marca y grupo de modelo.
class FavoriteIdentity extends Equatable {
  const FavoriteIdentity({
    required this.marketCode,
    required this.year,
    required this.brand,
    required this.groupKey,
    required this.modelName,
  });

  final String marketCode;
  final int year;
  final String brand;

  /// Clave estable del grupo de modelo dentro de la marca.
  final String groupKey;

  /// Nombre del grupo tal como se muestra.
  final String modelName;

  /// Clave única: mercado, año, marca y grupo (el nombre no entra).
  String get key => [
    marketCode,
    year,
    brand,
    groupKey,
  ].join(FavoritesConfig.identitySeparator);

  @override
  List<Object?> get props => [marketCode, year, brand, groupKey, modelName];
}
