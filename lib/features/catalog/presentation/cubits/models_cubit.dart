import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/models_state.dart';

/// Carga los modelos de una marca agrupados y los muestra por páginas.
class ModelsCubit extends Cubit<ModelsState> {
  ModelsCubit({required this.getModelGroups}) : super(const ModelsInitial());

  final GetModelGroupsUseCase getModelGroups;

  /// Indica si quedan grupos por mostrar.
  bool get hasMore {
    final current = state;
    return current is ModelsLoaded &&
        current.visibleCount < current.groups.length;
  }

  /// Carga los modelos; con la misma marca ya cargada refresca en el lugar.
  Future<void> load(int year, String brand) async {
    final current = state;
    final base = current is ModelsLoaded && current.brand == brand
        ? current
        : null;
    emit(base == null ? const ModelsLoading() : base.refreshing());
    try {
      final groups = await getModelGroups(year, brand);
      emit(
        ModelsLoaded(
          groups: groups,
          visibleCount: math.min(CatalogConfig.defaultPageSize, groups.length),
          year: year,
          brand: brand,
        ),
      );
    } on AppFailure catch (failure) {
      _emitFailure(base, year, brand, failure);
    } catch (error) {
      _emitFailure(base, year, brand, UnknownFailure(error.toString()));
    }
  }

  // Con datos previos conserva la lista; sin ellos muestra el error.
  void _emitFailure(
    ModelsLoaded? base,
    int year,
    String brand,
    AppFailure failure,
  ) {
    emit(
      base == null
          ? ModelsError(failure, year: year, brand: brand)
          : base.failedRefresh(
              ModelsRequest(year: year, brand: brand),
              failure,
            ),
    );
  }

  /// Repite la consulta pedida que falló, no la que se está mostrando.
  Future<void> retry() async {
    final current = state;
    if (current is ModelsError) {
      await load(current.year, current.brand);
    } else if (current is ModelsLoaded) {
      final request = current.failedRequest;
      if (request != null) await load(request.year, request.brand);
    }
  }

  /// Muestra una página más sin pasar del total; no emite si ya se ve todo.
  void loadMore() {
    final current = state;
    if (current is! ModelsLoaded || current.isRefreshing || !hasMore) return;
    emit(
      current.copyWith(
        visibleCount: math.min(
          current.visibleCount + CatalogConfig.defaultPageSize,
          current.groups.length,
        ),
      ),
    );
  }
}
