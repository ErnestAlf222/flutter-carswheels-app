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
    this.otherResults = const [],
    this.brandMatches = const [],
    this.suggestions = const [],
    this.recents = const [],
    this.brands = const [],
    this.scopeBrand,
    this.searchedText = '',
    this.focusRequestId = 0,
    this.otherYears,
    this.otherYearsFailed = false,
    this.canOfferOtherYears = false,
    this.filters = SearchFiltersEntity.none,
    this.traits = const {},
    this.isAnalyzing = false,
    this.isSearching = false,
  });

  /// Texto tal como está en el campo.
  final String query;

  /// Mercado y año vigentes; nulo mientras el catálogo no está listo.
  final SearchScopeEntity? scope;

  /// Estado del índice; nulo si aún no hay ni las marcas.
  final SearchIndexStatusEntity? indexStatus;

  /// La construcción falló antes de tener datos.
  final bool indexFailed;

  /// Con alcance de marca, los de esa marca; sin alcance, todas las coincidencias.
  final List<SearchResultEntity> results;

  /// Coincidencias de las demás marcas cuando hay alcance de marca.
  final List<SearchResultEntity> otherResults;

  /// Marcas cuyo nombre coincide con el texto.
  final List<String> brandMatches;

  /// Correcciones ofrecidas cuando la consulta no encontró nada.
  final List<String> suggestions;
  final List<RecentSearchEntity> recents;

  /// Todas las marcas del índice, en orden alfabético.
  final List<String> brands;

  /// Marca elegida como alcance suave; nula si se busca sin preferencia.
  final String? scopeBrand;

  /// Texto normalizado con el que se calcularon los resultados vigentes.
  final String searchedText;

  /// Sube cada vez que otra pantalla pide enfocar el campo.
  final int focusRequestId;

  /// Búsqueda en otros años; nula mientras nadie la pidió.
  final SearchOtherYearsStatusEntity? otherYears;

  /// La búsqueda en otros años terminó con error.
  final bool otherYearsFailed;

  /// El catálogo del mercado tiene otros años donde buscar.
  final bool canOfferOtherYears;

  /// Filtros y orden elegidos para las secciones de resultados.
  final SearchFiltersEntity filters;

  /// Rasgos ya analizados de los resultados, por clave de resultado.
  final Map<String, SearchResultTraitsEntity> traits;

  /// Hay un análisis de motorización y consumo en curso.
  final bool isAnalyzing;

  /// El texto vigente aún no se calma o su búsqueda no termina: no hay certeza.
  final bool isSearching;

  /// Resultados que se analizan (los de la marca primero), hasta el tope.
  List<SearchResultEntity> get analysisCandidates => [
    ...results,
    ...otherResults,
  ].take(SearchConfig.analysisMaxResults).toList();

  /// Resultados de otros años que se analizan, hasta su propio tope.
  List<SearchResultEntity> get otherYearsCandidates =>
      [...?otherYears?.results]
          .take(SearchConfig.otherYearsAnalysisMaxResults)
          .toList();

  /// Cuántos de los resultados de otros años ya tienen sus rasgos.
  int get otherYearsAnalyzedCount => otherYearsCandidates
      .where((result) => traits.containsKey(result.traitsKey))
      .length;

  /// Cuántos de los resultados a analizar ya tienen sus rasgos.
  int get analyzedCount => analysisCandidates
      .where((result) => traits.containsKey(result.traitsKey))
      .length;

  /// Hay algo que buscar: una marca como alcance o texto que llega al mínimo.
  bool get hasQuery =>
      scopeBrand != null ||
      TextNormalizer.normalize(query).length >= SearchConfig.minQueryLength;

  /// Cambia cuando los resultados pertenecen a otra búsqueda (alcance, marca o texto).
  String get resultsKey =>
      [scope?.key ?? '', scopeBrand ?? '', searchedText].join(' ');

  /// Hay texto suficiente para buscar por nombre.
  bool get hasText =>
      TextNormalizer.normalize(query).length >= SearchConfig.minQueryLength;

  /// Total de tarjetas de modelo mostradas.
  int get totalResults => results.length + otherResults.length;

  /// La lista llegó al tope de resultados: puede haber más.
  bool get isTruncated => hasText && totalResults >= SearchConfig.maxResults;

  /// El índice aún no termina (o ni empezó) y no ha fallado.
  bool get isPreparing =>
      !indexFailed &&
      (indexStatus == null || indexStatus!.phase == SearchIndexPhase.building);

  /// Falló sin ningún dato que mostrar.
  bool get hasBlockingError => indexFailed && indexStatus == null;

  /// Terminó con marcas sin grupos.
  bool get isPartial => indexStatus?.phase == SearchIndexPhase.partial;

  /// Con consulta, la búsqueda terminó, el texto se calmó y el índice está completo.
  bool get hasNoResults =>
      hasQuery &&
      !isSearching &&
      totalResults == 0 &&
      indexStatus?.phase == SearchIndexPhase.ready;

  /// Con alcance y texto, ninguna coincidencia cayó dentro de la marca.
  bool get hasNoResultsInScope =>
      scopeBrand != null &&
      hasText &&
      results.isEmpty &&
      otherResults.isNotEmpty;

  /// Se puede ofrecer buscar en otros años: hay texto, índice listo y años cercanos.
  bool get canSearchOtherYears =>
      hasText && canOfferOtherYears && otherYears == null && !isPreparing;

  SearchState copyWith({
    String? query,
    SearchScopeEntity? scope,
    bool clearScope = false,
    SearchIndexStatusEntity? indexStatus,
    bool clearIndexStatus = false,
    bool? indexFailed,
    List<SearchResultEntity>? results,
    List<SearchResultEntity>? otherResults,
    List<String>? brandMatches,
    List<String>? suggestions,
    List<RecentSearchEntity>? recents,
    List<String>? brands,
    String? scopeBrand,
    bool clearScopeBrand = false,
    String? searchedText,
    int? focusRequestId,
    SearchOtherYearsStatusEntity? otherYears,
    bool clearOtherYears = false,
    bool? otherYearsFailed,
    bool? canOfferOtherYears,
    SearchFiltersEntity? filters,
    Map<String, SearchResultTraitsEntity>? traits,
    bool? isAnalyzing,
    bool? isSearching,
  }) => SearchState(
    query: query ?? this.query,
    scope: clearScope ? null : scope ?? this.scope,
    indexStatus: clearIndexStatus ? null : indexStatus ?? this.indexStatus,
    indexFailed: indexFailed ?? this.indexFailed,
    results: results ?? this.results,
    otherResults: otherResults ?? this.otherResults,
    brandMatches: brandMatches ?? this.brandMatches,
    suggestions: suggestions ?? this.suggestions,
    recents: recents ?? this.recents,
    brands: brands ?? this.brands,
    scopeBrand: clearScopeBrand ? null : scopeBrand ?? this.scopeBrand,
    searchedText: searchedText ?? this.searchedText,
    focusRequestId: focusRequestId ?? this.focusRequestId,
    otherYears: clearOtherYears ? null : otherYears ?? this.otherYears,
    otherYearsFailed: otherYearsFailed ?? this.otherYearsFailed,
    canOfferOtherYears: canOfferOtherYears ?? this.canOfferOtherYears,
    filters: filters ?? this.filters,
    traits: traits ?? this.traits,
    isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    isSearching: isSearching ?? this.isSearching,
  );

  @override
  List<Object?> get props => [
    query,
    scope,
    indexStatus,
    indexFailed,
    results,
    otherResults,
    brandMatches,
    suggestions,
    recents,
    brands,
    scopeBrand,
    searchedText,
    focusRequestId,
    otherYears,
    otherYearsFailed,
    canOfferOtherYears,
    filters,
    traits,
    isAnalyzing,
    isSearching,
  ];
}
