import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';

/// Estado de la búsqueda: consulta, índice, resultados y recientes.
class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.scope,
    this.indexStatus,
    this.indexFailed = false,
    this.results = const [],
    this.recents = const [],
    this.quickBrands = const [],
    this.brandFilter,
    this.focusRequestId = 0,
  });

  /// Texto tal como está en el campo.
  final String query;

  /// Mercado y año vigentes; nulo mientras el catálogo no está listo.
  final SearchScopeEntity? scope;

  /// Estado del índice; nulo si aún no hay ni las marcas.
  final SearchIndexStatusEntity? indexStatus;

  /// La construcción falló antes de tener datos.
  final bool indexFailed;
  final List<SearchResultEntity> results;
  final List<RecentSearchEntity> recents;

  /// Marcas con más grupos, para los accesos rápidos.
  final List<String> quickBrands;

  /// Marca cuyos grupos se listan; nula en la búsqueda normal.
  final String? brandFilter;

  /// Sube cada vez que otra pantalla pide enfocar el campo.
  final int focusRequestId;

  /// Hay algo que buscar: una marca elegida o texto que llega al mínimo.
  bool get hasQuery =>
      brandFilter != null ||
      TextNormalizer.normalize(query).length >= SearchConfig.minQueryLength;

  /// El índice aún no termina (o ni empezó) y no ha fallado.
  bool get isPreparing =>
      !indexFailed &&
      (indexStatus == null || indexStatus!.phase == SearchIndexPhase.building);

  /// Falló sin ningún dato que mostrar.
  bool get hasBlockingError => indexFailed && indexStatus == null;

  /// Terminó con marcas sin grupos.
  bool get isPartial => indexStatus?.phase == SearchIndexPhase.partial;

  /// Con consulta, el índice terminó y no hubo coincidencias.
  bool get hasNoResults =>
      hasQuery &&
      results.isEmpty &&
      indexStatus != null &&
      indexStatus!.phase != SearchIndexPhase.building;

  SearchState copyWith({
    String? query,
    SearchScopeEntity? scope,
    bool clearScope = false,
    SearchIndexStatusEntity? indexStatus,
    bool clearIndexStatus = false,
    bool? indexFailed,
    List<SearchResultEntity>? results,
    List<RecentSearchEntity>? recents,
    List<String>? quickBrands,
    String? brandFilter,
    bool clearBrandFilter = false,
    int? focusRequestId,
  }) => SearchState(
    query: query ?? this.query,
    scope: clearScope ? null : scope ?? this.scope,
    indexStatus: clearIndexStatus ? null : indexStatus ?? this.indexStatus,
    indexFailed: indexFailed ?? this.indexFailed,
    results: results ?? this.results,
    recents: recents ?? this.recents,
    quickBrands: quickBrands ?? this.quickBrands,
    brandFilter: clearBrandFilter ? null : brandFilter ?? this.brandFilter,
    focusRequestId: focusRequestId ?? this.focusRequestId,
  );

  @override
  List<Object?> get props => [
    query,
    scope,
    indexStatus,
    indexFailed,
    results,
    recents,
    quickBrands,
    brandFilter,
    focusRequestId,
  ];
}
