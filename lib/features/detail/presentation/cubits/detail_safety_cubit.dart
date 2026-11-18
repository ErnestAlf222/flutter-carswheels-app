import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/domain/domain.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/detail_safety_state.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';

/// Carga las estrellas y los recalls NHTSA de un grupo, cada uno por su cuenta.
class DetailSafetyCubit extends Cubit<DetailSafetyState> {
  DetailSafetyCubit(this.resolveGroupSafety) : super(const DetailSafetyState());

  final ResolveGroupSafetyUseCase resolveGroupSafety;

  /// Pide ambas partes a la vez, sin reintentos; una falla no afecta a la otra.
  Future<void> load(DetailArgsEntity args) async {
    await Future.wait([_loadRatings(args), _loadRecalls(args)]);
  }

  Future<void> _loadRatings(DetailArgsEntity args) async {
    final SafetyLoad<GroupSafetyEntity> result;
    try {
      final safety = await resolveGroupSafety.resolveSafety(
        year: args.year,
        make: args.brand,
        model: args.groupName,
      );
      // Sin emparejar o sin calificación general: no hay estrellas que mostrar.
      result = safety == null || safety.maxOverall == null
          ? const SafetyEmpty<GroupSafetyEntity>()
          : SafetyData(safety);
    } on AppFailure catch (failure) {
      _emitRatings(SafetyFailed(failure));
      return;
    } catch (error) {
      _emitRatings(SafetyFailed(UnknownFailure(error.toString())));
      return;
    }
    _emitRatings(result);
  }

  Future<void> _loadRecalls(DetailArgsEntity args) async {
    final SafetyLoad<RecallSummaryEntity> result;
    try {
      final summary = await resolveGroupSafety.resolveRecalls(
        year: args.year,
        make: args.brand,
        model: args.groupName,
      );
      // Nulo es "sin dato", nunca cero; el cero solo llega con la lista vacía.
      result = summary == null
          ? const SafetyEmpty<RecallSummaryEntity>()
          : SafetyData(summary);
    } on AppFailure catch (failure) {
      _emitRecalls(SafetyFailed(failure));
      return;
    } catch (error) {
      _emitRecalls(SafetyFailed(UnknownFailure(error.toString())));
      return;
    }
    _emitRecalls(result);
  }

  // Si Detalle ya se cerró, el resultado se ignora.
  void _emitRatings(SafetyLoad<GroupSafetyEntity> result) {
    if (isClosed) return;
    emit(state.copyWith(ratings: result));
  }

  void _emitRecalls(SafetyLoad<RecallSummaryEntity> result) {
    if (isClosed) return;
    emit(state.copyWith(recalls: result));
  }
}
