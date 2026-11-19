import 'package:cars_wheels_app/core/algorithms/algorithms.dart';
import 'package:cars_wheels_app/features/search/domain/datasources/search_traits_source.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_filters_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_result_entity.dart';

/// Cuenta opciones y aplica filtros y orden a los resultados, sin Flutter.
class SearchFilterService {
  const SearchFilterService({required this.sortStrategy});

  final SortStrategy<SearchResultEntity> sortStrategy;

  /// Aplica marcas, motorizaciones y orden. Con filtro de motorización, un
  /// resultado sin analizar o sin dato de motorización no se muestra.
  List<SearchResultEntity> apply(
    List<SearchResultEntity> results,
    SearchFiltersEntity filters,
    Map<String, SearchResultTraitsEntity> traits,
  ) {
    final kept = [
      for (final result in results)
        if (_matchesBrands(result, filters) &&
            _matchesEngines(result, filters, traits))
          result,
    ];
    return _sorted(kept, filters.sort, traits);
  }

  /// Resultados por opción de motorización, aplicando solo el filtro de marcas.
  /// Un grupo con variantes de varios tipos cuenta en cada opción que contiene.
  Map<SearchEngineOption, int> engineCounts(
    List<SearchResultEntity> results,
    SearchFiltersEntity filters,
    Map<String, SearchResultTraitsEntity> traits,
  ) {
    final counts = {for (final option in SearchEngineOption.values) option: 0};
    for (final result in results) {
      if (!_matchesBrands(result, filters)) continue;
      final engines = traits[result.traitsKey]?.engines ?? const {};
      for (final option in engines) {
        counts[option] = counts[option]! + 1;
      }
    }
    return counts;
  }

  /// Opciones de motorización que existen entre los resultados analizados,
  /// sin importar los demás filtros.
  Set<SearchEngineOption> availableEngines(
    List<SearchResultEntity> results,
    Map<String, SearchResultTraitsEntity> traits,
  ) => {for (final result in results) ...?traits[result.traitsKey]?.engines};

  /// Resultados por marca, aplicando solo el filtro de motorización.
  Map<String, int> brandCounts(
    List<SearchResultEntity> results,
    SearchFiltersEntity filters,
    Map<String, SearchResultTraitsEntity> traits,
  ) {
    final counts = <String, int>{};
    for (final result in results) {
      if (!_matchesEngines(result, filters, traits)) continue;
      counts[result.brand] = (counts[result.brand] ?? 0) + 1;
    }
    return counts;
  }

  /// Cuántos resultados (que pasan el filtro de marcas) siguen sin analizar.
  int unanalyzedCount(
    List<SearchResultEntity> results,
    SearchFiltersEntity filters,
    Map<String, SearchResultTraitsEntity> traits,
  ) => results
      .where(
        (result) =>
            _matchesBrands(result, filters) &&
            !traits.containsKey(result.traitsKey),
      )
      .length;

  bool _matchesBrands(SearchResultEntity result, SearchFiltersEntity filters) =>
      filters.brands.isEmpty || filters.brands.contains(result.brand);

  bool _matchesEngines(
    SearchResultEntity result,
    SearchFiltersEntity filters,
    Map<String, SearchResultTraitsEntity> traits,
  ) {
    if (filters.engines.isEmpty) return true;
    final engines = traits[result.traitsKey]?.engines;
    return engines != null && engines.any(filters.engines.contains);
  }

  List<SearchResultEntity> _sorted(
    List<SearchResultEntity> results,
    SearchSortOrder sort,
    Map<String, SearchResultTraitsEntity> traits,
  ) {
    if (sort == SearchSortOrder.relevance) return results;
    // El orden original desempata: así el resultado es estable.
    final position = <SearchResultEntity, int>{};
    for (final result in results) {
      position.putIfAbsent(result, () => position.length);
    }
    int byPosition(SearchResultEntity a, SearchResultEntity b) =>
        position[a]!.compareTo(position[b]!);
    final Comparator<SearchResultEntity> compare;
    if (sort == SearchSortOrder.alphabetical) {
      compare = (a, b) {
        final byName = _nameOf(a).compareTo(_nameOf(b));
        return byName != 0 ? byName : byPosition(a, b);
      };
    } else {
      compare = (a, b) {
        final kmA = traits[a.traitsKey]?.maxKmPerLiter;
        final kmB = traits[b.traitsKey]?.maxKmPerLiter;
        // Sin dato (nulo, sin analizar o eléctrico) va al final; nunca se vuelve 0.
        if (kmA == null || kmB == null) {
          if (kmA == null && kmB == null) return byPosition(a, b);
          return kmA == null ? 1 : -1;
        }
        final byKm = kmB.compareTo(kmA);
        return byKm != 0 ? byKm : byPosition(a, b);
      };
    }
    return sortStrategy.sort(results, compare);
  }

  String _nameOf(SearchResultEntity result) => TextNormalizer.normalize(
    '${result.groupName ?? result.brand} ${result.brand}',
  );
}
