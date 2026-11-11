import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/models_state.dart';

/// Carga los modelos de una marca y los muestra por páginas.
class ModelsCubit extends Cubit<ModelsState> {
  ModelsCubit({
    required this.getModels,
    this.minimumLoadingTime = const Duration(
      milliseconds: UiConfig.loaderMinimumVisibleMilliseconds,
    ),
  }) : super(const ModelsInitial());

  final GetModelsUseCase getModels;

  /// Tiempo mínimo que el estado loading permanece visible.
  final Duration minimumLoadingTime;

  /// Indica si quedan modelos por mostrar.
  bool get hasMore {
    final current = state;
    return current is ModelsLoaded &&
        current.visibleCount < current.models.length;
  }

  Future<void> load(int year, String brand) async {
    final loadingTimer = Stopwatch()..start();
    emit(const ModelsLoading());
    try {
      final models = await getModels(year, brand);
      await _waitMinimumLoading(loadingTimer);
      emit(
        ModelsLoaded(
          models: models,
          visibleCount: math.min(CatalogConfig.defaultPageSize, models.length),
        ),
      );
    } on AppFailure catch (failure) {
      await _waitMinimumLoading(loadingTimer);
      emit(ModelsError(failure, year: year, brand: brand));
    } catch (error) {
      await _waitMinimumLoading(loadingTimer);
      emit(
        ModelsError(UnknownFailure(error.toString()), year: year, brand: brand),
      );
    }
  }

  /// Repite la consulta que falló con el mismo año y marca.
  Future<void> retry() async {
    final current = state;
    if (current is! ModelsError) return;
    await load(current.year, current.brand);
  }

  /// Muestra una página más sin pasar del total; no emite si ya se ve todo.
  void loadMore() {
    final current = state;
    if (current is! ModelsLoaded || !hasMore) return;
    emit(
      ModelsLoaded(
        models: current.models,
        visibleCount: math.min(
          current.visibleCount + CatalogConfig.defaultPageSize,
          current.models.length,
        ),
      ),
    );
  }

  // Completa el tiempo mínimo de loader pendiente.
  Future<void> _waitMinimumLoading(Stopwatch loadingTimer) async {
    final remaining = minimumLoadingTime - loadingTimer.elapsed;
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);
  }
}
