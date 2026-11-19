import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/search/domain/entities/search_result_entity.dart';

/// Resultado de una búsqueda global con alcance suave de marca.
class SearchResponseEntity extends Equatable {
  const SearchResponseEntity({
    this.primary = const [],
    this.others = const [],
    this.brandMatches = const [],
  });

  /// Sin coincidencias.
  static const SearchResponseEntity empty = SearchResponseEntity();

  /// Con alcance de marca, los de esa marca; sin alcance, todas las coincidencias.
  final List<SearchResultEntity> primary;

  /// Coincidencias de las demás marcas (vacío sin alcance).
  final List<SearchResultEntity> others;

  /// Marcas cuyo nombre coincide con el texto (sin la marca del alcance).
  final List<String> brandMatches;

  bool get isEmpty => primary.isEmpty && others.isEmpty;

  @override
  List<Object?> get props => [primary, others, brandMatches];
}
