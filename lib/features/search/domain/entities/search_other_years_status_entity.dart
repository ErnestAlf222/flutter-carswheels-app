import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/search/domain/entities/search_result_entity.dart';

/// Fase de la búsqueda en otros años.
enum SearchOtherYearsPhase { building, done }

/// Avance y hallazgos de la búsqueda en los años más cercanos.
class SearchOtherYearsStatusEntity extends Equatable {
  const SearchOtherYearsStatusEntity({
    required this.phase,
    required this.progress,
    required this.checkedYears,
    this.results = const [],
    this.failedYears = const [],
  });

  final SearchOtherYearsPhase phase;

  /// Avance de 0 a 1 sobre todos los años pedidos.
  final double progress;

  /// Años que se buscan (o se buscaron), del más cercano al más lejano.
  final List<int> checkedYears;

  /// Coincidencias de los años ya terminados.
  final List<SearchResultEntity> results;

  /// Años que no pudieron indexarse.
  final List<int> failedYears;

  bool get isBuilding => phase == SearchOtherYearsPhase.building;

  @override
  List<Object?> get props => [
    phase,
    progress,
    checkedYears,
    results,
    failedYears,
  ];
}
