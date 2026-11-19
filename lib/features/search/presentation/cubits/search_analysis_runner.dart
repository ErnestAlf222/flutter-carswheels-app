import 'dart:async';
import 'dart:math';

import 'package:cars_wheels_app/core/config/search_config.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';

/// Rasgos obtenidos de un resultado durante el análisis.
class SearchTraitsUpdate {
  const SearchTraitsUpdate({required this.result, required this.traits});

  final SearchResultEntity result;
  final SearchResultTraitsEntity traits;
}

/// Pide los rasgos de los resultados con concurrencia limitada y en una sola cola.
class SearchAnalysisRunner {
  const SearchAnalysisRunner({
    required this.source,
    this.maxConcurrent = SearchConfig.analysisConcurrency,
    this.maxResults = SearchConfig.analysisMaxResults,
  }) : assert(maxConcurrent > 0);

  final SearchTraitsSource source;
  final int maxConcurrent;

  /// Tope de resultados analizados en una corrida.
  final int maxResults;

  /// Emite cada rasgo al obtenerse y cierra al terminar. Cancelar la suscripción
  /// detiene los pedidos que no empezaron; un resultado que falla se omite.
  Stream<SearchTraitsUpdate> run(List<SearchResultEntity> results) {
    final queue = results.take(maxResults).toList();
    final state = _RunState();
    late final StreamController<SearchTraitsUpdate> controller;
    controller = StreamController<SearchTraitsUpdate>(
      onListen: () {
        final workers = List.generate(
          min(maxConcurrent, queue.length),
          (_) => _work(queue, state, controller),
        );
        unawaited(
          Future.wait(workers).whenComplete(() {
            if (!controller.isClosed) unawaited(controller.close());
          }),
        );
      },
      onCancel: () => state.cancelled = true,
    );
    return controller.stream;
  }

  Future<void> _work(
    List<SearchResultEntity> queue,
    _RunState state,
    StreamController<SearchTraitsUpdate> controller,
  ) async {
    while (!state.cancelled && state.next < queue.length) {
      final result = queue[state.next++];
      try {
        final traits = await source.traitsOf(result);
        if (state.cancelled) return;
        controller.add(SearchTraitsUpdate(result: result, traits: traits));
      } on Object {
        // Un resultado que no se pudo analizar queda sin analizar.
      }
    }
  }
}

// Estado mutable de una corrida: siguiente resultado y si se canceló.
class _RunState {
  int next = 0;
  bool cancelled = false;
}
