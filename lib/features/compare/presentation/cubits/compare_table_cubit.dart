import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/cubits/compare_cubit.dart';
import 'package:cars_wheels_app/features/compare/presentation/cubits/compare_state.dart';
import 'package:cars_wheels_app/features/compare/presentation/cubits/compare_table_state.dart';

/// Carga los datos de cada vehículo del comparador, una columna por su cuenta.
///
/// Sigue la selección del [CompareCubit]: pide lo que falta, descarta lo que
/// sale y no repite lo ya cargado. Las cachés de las fuentes evitan la red.
class CompareTableCubit extends Cubit<CompareTableState> {
  CompareTableCubit({
    required this.compare,
    required this.vehicleSource,
    required this.safetySource,
  }) : super(const CompareTableState()) {
    _subscription = compare.stream.listen(_onCompare);
    _onCompare(compare.state);
  }

  final CompareCubit compare;
  final CompareVehicleSource vehicleSource;
  final CompareSafetySource safetySource;

  // Recurso cancelable: la suscripción a la selección.
  StreamSubscription<CompareState>? _subscription;

  /// Vuelve a pedir un vehículo cuya carga falló.
  void retry(CompareSlotEntity slot) {
    if (state.columns[slot.identity] is! CompareColumnFailed) return;
    unawaited(_load(slot));
  }

  /// Al volver la conexión: repite una vez las columnas que fallaron.
  void restoreAfterReconnect() {
    final current = compare.state;
    if (current is! CompareLoaded) return;
    for (final slot in current.selection.slots) {
      retry(slot);
    }
  }

  void _onCompare(CompareState compareState) {
    if (compareState is! CompareLoaded) return;
    final slots = compareState.selection.slots;
    final identities = {for (final slot in slots) slot.identity};
    final kept = {
      for (final entry in state.columns.entries)
        if (identities.contains(entry.key)) entry.key: entry.value,
    };
    final missing = [
      for (final slot in slots)
        if (!kept.containsKey(slot.identity)) slot,
    ];
    emit(
      CompareTableState({
        ...kept,
        for (final slot in missing) slot.identity: const CompareColumnLoading(),
      }),
    );
    for (final slot in missing) {
      unawaited(_load(slot));
    }
  }

  Future<void> _load(CompareSlotEntity slot) async {
    _set(slot, const CompareColumnLoading());
    final CompareColumnState result;
    try {
      // Las dos consultas arrancan juntas; las estrellas nunca lanzan.
      final starsFuture = _stars(slot);
      final detail = await vehicleSource.detailOf(slot);
      final stars = await starsFuture;
      result = CompareColumnLoaded(
        (detail ?? const CompareVehicleDetailEntity()).withSafetyStars(stars),
      );
    } catch (_) {
      _set(slot, const CompareColumnFailed());
      return;
    }
    _set(slot, result);
  }

  // Sin calificación o con la consulta caída, las estrellas quedan en "—".
  Future<int?> _stars(CompareSlotEntity slot) async {
    try {
      return await safetySource.overallStarsOf(slot);
    } catch (_) {
      return null;
    }
  }

  // Ignora resultados de vehículos que ya salieron de la selección.
  void _set(CompareSlotEntity slot, CompareColumnState column) {
    if (isClosed || !state.columns.containsKey(slot.identity)) return;
    emit(CompareTableState({...state.columns, slot.identity: column}));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
