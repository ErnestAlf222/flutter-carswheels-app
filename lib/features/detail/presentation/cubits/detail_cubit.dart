import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/domain/domain.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/detail_state.dart';

/// Carga las versiones de un grupo y guarda cuál está seleccionada.
class DetailCubit extends Cubit<DetailState> {
  DetailCubit(this.loadGroupDetails) : super(const DetailInitial());

  final LoadGroupDetailsUseCase loadGroupDetails;

  // Última carga pedida (a lo más una); sirve para retry y descarta resultados viejos.
  final List<({DetailArgsEntity args, Object token})> _current = [];

  /// Carga las versiones y selecciona la mediana.
  Future<void> load(DetailArgsEntity args) async {
    if (isClosed) return;
    final token = Object();
    _current
      ..clear()
      ..add((args: args, token: token));
    emit(const DetailLoading());
    final DetailState result;
    try {
      final details = await loadGroupDetails(args);
      result = details.versions.isEmpty
          ? const DetailEmpty()
          : DetailLoaded(details: details, selectedIndex: details.defaultIndex);
    } on AppFailure catch (failure) {
      _emitResult(token, DetailError(failure));
      return;
    } catch (error) {
      _emitResult(token, DetailError(UnknownFailure(error.toString())));
      return;
    }
    _emitResult(token, result);
  }

  /// Repite la última carga; no hace nada si nunca se cargó.
  Future<void> retry() async {
    if (_current.isEmpty) return;
    await load(_current.first.args);
  }

  /// Cambia la versión seleccionada; ignora índices inválidos o repetidos.
  void select(int index) {
    final current = state;
    if (current is! DetailLoaded) return;
    final isValid = index >= 0 && index < current.details.versions.length;
    if (!isValid || index == current.selectedIndex) return;
    emit(DetailLoaded(details: current.details, selectedIndex: index));
  }

  void _emitResult(Object token, DetailState result) {
    final isLatest = _current.isNotEmpty && _current.first.token == token;
    if (isClosed || !isLatest) return;
    emit(result);
  }
}
