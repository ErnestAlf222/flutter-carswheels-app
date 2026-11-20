import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_index_status_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_other_years_status_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_result_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_scope_entity.dart';
import 'package:cars_wheels_app/features/search/domain/services/nearest_years_selector.dart';
import 'package:cars_wheels_app/features/search/domain/usecases/build_search_index_usecase.dart';
import 'package:cars_wheels_app/features/search/domain/usecases/search_catalog_usecase.dart';

/// Busca la consulta en los años más cercanos, construyendo sus índices bajo demanda.
///
/// Usa su propio [BuildSearchIndexUseCase] (con el mismo almacén y las mismas
/// cachés que el índice principal), así no interrumpe la construcción del año
/// vigente. Un año ya indexado en la sesión no vuelve a pedir nada.
class SearchOtherYearsUseCase {
  SearchOtherYearsUseCase({
    required this.buildIndex,
    required this.searchCatalog,
    required this.selector,
  });

  final BuildSearchIndexUseCase buildIndex;
  final SearchCatalogUseCase searchCatalog;
  final NearestYearsSelector selector;

  // Número de la corrida vigente; cancelar lo cambia y las anteriores terminan.
  int _runId = 0;

  /// Emite el avance; el último estado tiene la fase terminada.
  Stream<SearchOtherYearsStatusEntity> call({
    required SearchScopeEntity scope,
    required String query,
    required List<int> availableYears,
  }) async* {
    final runId = ++_runId;
    bool cancelled() => runId != _runId;
    final years = selector.select(
      available: availableYears,
      currentYear: scope.year,
    );
    final results = <SearchResultEntity>[];
    final failed = <int>[];
    SearchOtherYearsStatusEntity status(
      SearchOtherYearsPhase phase,
      double progress,
    ) => SearchOtherYearsStatusEntity(
      phase: phase,
      progress: progress,
      checkedYears: years,
      results: List.unmodifiable(results),
      failedYears: List.unmodifiable(failed),
    );

    yield status(SearchOtherYearsPhase.building, 0);
    for (final (position, year) in years.indexed) {
      if (cancelled()) return;
      final yearScope = SearchScopeEntity(
        marketCode: scope.marketCode,
        year: year,
      );
      try {
        SearchIndexStatusEntity? lastStatus;
        await for (final indexStatus in buildIndex(yearScope)) {
          if (cancelled()) return;
          lastStatus = indexStatus;
          final inner = indexStatus.phase == SearchIndexPhase.building
              ? indexStatus.progress
              : 1.0;
          yield status(
            SearchOtherYearsPhase.building,
            (position + inner) / years.length,
          );
        }
        if (cancelled()) return;
        // Un año con marcas sin indexar se avisa, pero sus coincidencias se muestran.
        if (lastStatus?.phase == SearchIndexPhase.partial) failed.add(year);
        results.addAll(searchCatalog(yearScope, query));
        if (results.length > SearchConfig.maxOtherYearsResults) {
          results.removeRange(
            SearchConfig.maxOtherYearsResults,
            results.length,
          );
        }
      } on Object {
        if (cancelled()) return;
        failed.add(year);
      }
    }
    if (cancelled()) return;
    yield status(SearchOtherYearsPhase.done, 1);
  }

  /// Cancela la construcción en curso; el flujo termina sin más estados.
  void cancel() {
    _runId++;
    buildIndex.cancel();
  }
}
