import 'package:equatable/equatable.dart';

/// Opción de motorización del filtro de búsqueda.
enum SearchEngineOption { electric, hybrid, pluginHybrid, combustion }

/// Orden de los resultados: el de relevancia original, A–Z o más eficiente.
enum SearchSortOrder { relevance, alphabetical, mostEfficient }

/// Filtros y orden elegidos para los resultados de búsqueda.
class SearchFiltersEntity extends Equatable {
  const SearchFiltersEntity({
    this.engines = const {},
    this.brands = const {},
    this.sort = SearchSortOrder.relevance,
  });

  /// Sin filtros ni orden.
  static const SearchFiltersEntity none = SearchFiltersEntity();

  final Set<SearchEngineOption> engines;
  final Set<String> brands;
  final SearchSortOrder sort;

  /// Cuántos filtros hay activos (cada opción elegida y el orden si no es el original).
  int get activeCount =>
      engines.length +
      brands.length +
      (sort == SearchSortOrder.relevance ? 0 : 1);

  bool get isActive => activeCount > 0;

  /// Para filtrar u ordenar hace falta conocer la motorización o el consumo.
  bool get needsTraits =>
      engines.isNotEmpty || sort == SearchSortOrder.mostEfficient;

  SearchFiltersEntity copyWith({
    Set<SearchEngineOption>? engines,
    Set<String>? brands,
    SearchSortOrder? sort,
  }) => SearchFiltersEntity(
    engines: engines ?? this.engines,
    brands: brands ?? this.brands,
    sort: sort ?? this.sort,
  );

  @override
  List<Object?> get props => [engines, brands, sort];
}
