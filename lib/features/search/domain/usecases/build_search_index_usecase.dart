import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/datasources/search_catalog_source.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_entry_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_index_status_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_scope_entity.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_index.dart';
import 'package:cars_wheels_app/features/search/domain/services/search_index_store.dart';

/// Marca de una construcción en curso; cancelar la deja sin efecto.
class _BuildRun {
  bool cancelled = false;
}

/// Construye o recupera el índice de un mercado y año.
///
/// Primero indexa las marcas (ya se puede buscar por marca) y después los
/// grupos de cada una con concurrencia limitada. Una marca que falla deja el
/// índice parcial; las demás siguen. Pedir otro mercado o año cancela la
/// construcción anterior y descarta su índice incompleto.
class BuildSearchIndexUseCase {
  BuildSearchIndexUseCase({
    required this.source,
    required this.store,
    required this.sortStrategy,
  });

  final SearchCatalogSource source;
  final SearchIndexStore store;
  final SortStrategy<SearchPosting> sortStrategy;

  _BuildRun? _active;
  String? _activeKey;

  /// Emite el estado del índice; si ya existe, lo emite y termina sin red.
  /// Con [retryFailedOnly] vuelve a pedir solo las marcas que fallaron.
  Stream<SearchIndexStatusEntity> call(
    SearchScopeEntity scope, {
    bool retryFailedOnly = false,
  }) {
    final existing = store.recordOf(scope.key);
    final isFinished =
        existing != null && existing.status.phase != SearchIndexPhase.building;
    final retry =
        retryFailedOnly &&
        isFinished &&
        existing.status.phase == SearchIndexPhase.partial;
    if (isFinished && !retry) return Stream.value(existing.status);
    // Otro mercado o año (o el mismo, reiniciado) cancela la anterior.
    cancel();
    final run = _BuildRun();
    _active = run;
    _activeKey = scope.key;
    // Dejar de escuchar el flujo cancela la construcción.
    final controller = StreamController<SearchIndexStatusEntity>(
      onCancel: () {
        if (identical(_active, run)) cancel();
      },
    );
    unawaited(_run(scope, run, controller, retry ? existing : null));
    return controller.stream;
  }

  /// Cancela la construcción en curso y descarta su índice incompleto.
  void cancel() {
    final run = _active;
    final key = _activeKey;
    if (run == null || key == null) return;
    run.cancelled = true;
    final record = store.recordOf(key);
    if (record?.status.phase == SearchIndexPhase.building) store.remove(key);
    _active = null;
    _activeKey = null;
  }

  Future<void> _run(
    SearchScopeEntity scope,
    _BuildRun run,
    StreamController<SearchIndexStatusEntity> controller,
    SearchIndexRecord? retryFrom,
  ) async {
    try {
      final entries = <SearchEntryEntity>[];
      final failed = <String>[];
      final List<String> pending;
      if (retryFrom == null) {
        final brands = await source.fetchBrands(scope);
        if (run.cancelled) return;
        entries.addAll([
          for (final brand in brands) SearchEntryEntity(brand: brand),
        ]);
        pending = List.of(brands);
      } else {
        entries.addAll(retryFrom.index.entries);
        pending = List.of(retryFrom.status.failedBrands);
      }
      final total = retryFrom?.status.totalBrands ?? pending.length;
      final alreadyDone = total - pending.length;
      final finished = <String>[];
      void publish() {
        final status = SearchIndexStatusEntity.building(
          completedBrands: alreadyDone + finished.length,
          totalBrands: total,
          failedBrands: List.unmodifiable(failed),
        );
        store.save(
          scope.key,
          SearchIndexRecord(
            index: SearchIndex.build(entries, sortStrategy),
            status: status,
          ),
        );
        controller.add(status);
      }

      publish();
      final queue = List.of(pending);
      Future<void> worker() async {
        while (queue.isNotEmpty && !run.cancelled) {
          final brand = queue.removeAt(0);
          try {
            final names = await source.fetchGroupNames(scope, brand);
            if (run.cancelled) return;
            entries.addAll([
              for (final name in names)
                SearchEntryEntity(brand: brand, groupName: name),
            ]);
          } on Object {
            if (run.cancelled) return;
            failed.add(brand);
          }
          finished.add(brand);
          publish();
        }
      }

      final workerCount = pending.length < SearchConfig.indexBuildConcurrency
          ? pending.length
          : SearchConfig.indexBuildConcurrency;
      await Future.wait(List.generate(workerCount, (_) => worker()));
      if (run.cancelled) return;
      final finalStatus = failed.isEmpty
          ? SearchIndexStatusEntity.ready(totalBrands: total)
          : SearchIndexStatusEntity.partial(
              totalBrands: total,
              failedBrands: List.unmodifiable(failed),
            );
      store.save(
        scope.key,
        SearchIndexRecord(
          index: SearchIndex.build(entries, sortStrategy),
          status: finalStatus,
        ),
      );
      controller.add(finalStatus);
    } on Object catch (error, stackTrace) {
      if (!run.cancelled) controller.addError(error, stackTrace);
    } finally {
      if (identical(_active, run)) {
        _active = null;
        _activeKey = null;
      }
      await controller.close();
    }
  }
}
