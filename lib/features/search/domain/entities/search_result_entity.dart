import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/config/search_config.dart';

/// Coincidencia de búsqueda: un grupo de modelo de una marca, con sus variantes.
class SearchResultEntity extends Equatable {
  const SearchResultEntity({
    required this.brand,
    required this.year,
    required this.marketCode,
    this.groupName,
    this.variantNames = const [],
  });

  final String brand;

  /// Nombre del grupo para mostrar; nulo cuando el resultado es solo la marca.
  final String? groupName;

  /// Variantes del grupo, para pedir su resumen y su foto.
  final List<String> variantNames;
  final int year;
  final String marketCode;

  bool get isBrandOnly => groupName == null;

  /// Clave estable para guardar los rasgos analizados de este resultado.
  String get traitsKey => [
    marketCode,
    year,
    brand,
    groupName ?? '',
  ].join(SearchConfig.scopeKeySeparator);

  @override
  List<Object?> get props => [brand, groupName, variantNames, year, marketCode];
}
