import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';

/// Estado de la carga de modelos.
sealed class ModelsState extends Equatable {
  const ModelsState();

  @override
  List<Object?> get props => [];
}

class ModelsInitial extends ModelsState {
  const ModelsInitial();
}

class ModelsLoading extends ModelsState {
  const ModelsLoading();
}

class ModelsLoaded extends ModelsState {
  const ModelsLoaded({
    required this.models,
    required this.visibleCount,
    required this.year,
    required this.brand,
    this.isRefreshing = false,
    this.refreshFailure,
  });

  /// Lista completa de modelos.
  final List<ModelEntity> models;

  /// Cantidad de modelos visibles hasta ahora.
  final int visibleCount;

  /// Año de la consulta; tras un refresco fallido, el año que se pidió.
  final int year;

  /// Marca de la consulta.
  final String brand;

  /// Verdadero mientras se pide una lista nueva de la misma marca.
  final bool isRefreshing;

  /// Fallo del último refresco; nulo si no hubo fallo.
  final AppFailure? refreshFailure;

  ModelsLoaded copyWith({int? visibleCount}) => ModelsLoaded(
    models: models,
    visibleCount: visibleCount ?? this.visibleCount,
    year: year,
    brand: brand,
    isRefreshing: isRefreshing,
    refreshFailure: refreshFailure,
  );

  /// Mismo contenido, refrescando y sin el fallo anterior.
  ModelsLoaded refreshing() => ModelsLoaded(
    models: models,
    visibleCount: visibleCount,
    year: year,
    brand: brand,
    isRefreshing: true,
  );

  /// Mismo contenido, sin refrescar y con el fallo de la consulta pedida.
  ModelsLoaded failedRefresh(int requestedYear, AppFailure failure) =>
      ModelsLoaded(
        models: models,
        visibleCount: visibleCount,
        year: requestedYear,
        brand: brand,
        refreshFailure: failure,
      );

  @override
  List<Object?> get props => [
    models,
    visibleCount,
    year,
    brand,
    isRefreshing,
    refreshFailure,
  ];
}

/// Fallo sin datos previos que mostrar.
class ModelsError extends ModelsState {
  const ModelsError(this.failure, {required this.year, required this.brand});

  final AppFailure failure;

  /// Año de la consulta que falló.
  final int year;

  /// Marca de la consulta que falló.
  final String brand;

  @override
  List<Object?> get props => [failure, year, brand];
}
