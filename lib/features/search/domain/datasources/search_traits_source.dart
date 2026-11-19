import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/search/domain/entities/search_filters_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_result_entity.dart';

/// Rasgos de un resultado ya analizado: motorizaciones y consumo máximo.
class SearchResultTraitsEntity extends Equatable {
  const SearchResultTraitsEntity({this.engines = const {}, this.maxKmPerLiter});

  /// Analizado, pero sin ningún dato.
  static const SearchResultTraitsEntity unknown = SearchResultTraitsEntity();

  /// Motorizaciones presentes; vacío si no hay dato (no se inventa).
  final Set<SearchEngineOption> engines;

  /// Mejor consumo de las variantes de combustión; nulo si no hay dato.
  final double? maxKmPerLiter;

  @override
  List<Object?> get props => [engines, maxKmPerLiter];
}

/// Rasgos de un resultado (motorización y consumo); lo implementa la capa app.
abstract class SearchTraitsSource {
  /// Lanza si no se pudo obtener; sin datos devuelve [SearchResultTraitsEntity.unknown].
  Future<SearchResultTraitsEntity> traitsOf(SearchResultEntity result);
}
