import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';

/// Textos de las opciones de filtro y resumen de los filtros activos.
class SearchFilterLabels {
  const SearchFilterLabels._();

  static String engine(SearchEngineOption option) => switch (option) {
    SearchEngineOption.electric => AppTexts.searchFiltersEngineElectric,
    SearchEngineOption.hybrid => AppTexts.searchFiltersEngineHybrid,
    SearchEngineOption.pluginHybrid => AppTexts.searchFiltersEnginePluginHybrid,
    SearchEngineOption.combustion => AppTexts.searchFiltersEngineCombustion,
  };

  static String sort(SearchSortOrder order) => switch (order) {
    SearchSortOrder.alphabetical => AppTexts.searchFiltersSortAlphabetical,
    SearchSortOrder.mostEfficient => AppTexts.searchFiltersSortMostEfficient,
    SearchSortOrder.relevance => '',
  };

  /// Una línea con lo aplicado: motorizaciones, marcas y orden.
  static String summary(SearchFiltersEntity filters) => [
    for (final option in SearchEngineOption.values)
      if (filters.engines.contains(option)) engine(option),
    ...filters.brands,
    if (filters.sort != SearchSortOrder.relevance) sort(filters.sort),
  ].join(AppTexts.searchFiltersSummarySeparator);
}
