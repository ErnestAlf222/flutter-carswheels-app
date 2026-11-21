import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/search/domain/entities/search_result_entity.dart';

/// Una página del feed y lo que queda por mostrar.
class SearchFeedPageEntity extends Equatable {
  const SearchFeedPageEntity({
    required this.results,
    required this.remaining,
    required this.isBuilding,
  });

  /// Sin índice o sin nada que mostrar todavía.
  static const SearchFeedPageEntity empty = SearchFeedPageEntity(
    results: [],
    remaining: 0,
    isBuilding: false,
  );

  /// Los modelos de esta página, en el orden en que se muestran.
  final List<SearchResultEntity> results;

  /// Modelos del índice que aún no se han mostrado, sin contar esta página.
  final int remaining;

  /// El índice sigue creciendo: pueden llegar más modelos después.
  final bool isBuilding;

  /// No queda nada y el índice ya no crece: es el final del catálogo.
  bool get isExhausted => remaining == 0 && results.isEmpty && !isBuilding;

  @override
  List<Object?> get props => [results, remaining, isBuilding];
}
