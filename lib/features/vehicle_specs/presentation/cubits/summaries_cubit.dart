import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/domain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/presentation/cubits/summaries_state.dart';
import 'package:cars_wheels_app/features/vehicle_specs/presentation/cubits/summary_request.dart';
import 'package:cars_wheels_app/features/vehicle_specs/presentation/cubits/summary_slot.dart';

/// Pide los resúmenes de los grupos y guarda el resultado de cada uno.
class SummariesCubit extends Cubit<SummariesState> {
  SummariesCubit({
    required this.resolveGroupSummary,
    required this.cancelPendingSummaries,
    required this.keyBuilder,
  }) : super(const SummariesState());

  final ResolveGroupSummaryUseCase resolveGroupSummary;
  final CancelPendingSummariesUseCase cancelPendingSummaries;
  final SummaryKeyBuilder keyBuilder;

  // Marca del último pedido por clave; descarta resultados de pedidos viejos.
  final Map<String, Object> _latestRequestByKey = {};

  /// Clave del espacio de un grupo.
  String keyFor(String brand, String groupName, int year) =>
      keyBuilder.build(brand: brand, groupName: groupName, year: year);

  /// Pide los resúmenes que faltan o fallaron, sin esperar uno por uno.
  void requestSummaries(List<SummaryRequest> requests) {
    final toResolve = <String, SummaryRequest>{};
    for (final request in requests) {
      final key = keyFor(request.brand, request.groupName, request.year);
      if (toResolve.containsKey(key)) continue;
      final slot = state.slots[key];
      if (slot == null || slot is SummaryFailed) toResolve[key] = request;
    }
    if (toResolve.isEmpty) return;
    emit(
      state.withSlots({
        for (final key in toResolve.keys) key: const SummaryLoading(),
      }),
    );
    for (final entry in toResolve.entries) {
      _resolve(entry.key, entry.value);
    }
  }

  /// Cancela lo pendiente; lo que seguía cargando queda listo para pedirse de nuevo.
  void cancelPending() {
    cancelPendingSummaries();
    final cancelled = <String, SummarySlot>{
      for (final entry in state.slots.entries)
        if (entry.value is SummaryLoading) entry.key: const SummaryFailed(),
    };
    if (cancelled.isEmpty) return;
    emit(state.withSlots(cancelled));
  }

  // Lanza la resolución y emite su resultado si sigue siendo el pedido vigente.
  Future<void> _resolve(String key, SummaryRequest request) async {
    final requestToken = Object();
    _latestRequestByKey[key] = requestToken;
    final SummarySlot result;
    try {
      final summary = await resolveGroupSummary(
        year: request.year,
        brand: request.brand,
        groupName: request.groupName,
        variantNames: request.variantNames,
      );
      result = summary == null ? const SummaryMissing() : SummaryFound(summary);
    } on CancelledFailure {
      // Cancelada a propósito: cancelPending ya dejó el espacio como fallido.
      return;
    } catch (_) {
      _emitResult(key, requestToken, const SummaryFailed());
      return;
    }
    _emitResult(key, requestToken, result);
  }

  void _emitResult(String key, Object requestToken, SummarySlot result) {
    if (isClosed || _latestRequestByKey[key] != requestToken) return;
    emit(state.withSlots({key: result}));
  }
}
