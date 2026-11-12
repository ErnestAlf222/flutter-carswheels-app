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

/// Consulta de modelos pedida: año y marca.
class ModelsRequest extends Equatable {
  const ModelsRequest({required this.year, required this.brand});

  final int year;
  final String brand;

  @override
  List<Object?> get props => [year, brand];
}

class ModelsLoaded extends ModelsState {
  const ModelsLoaded({
    required this.groups,
    required this.visibleCount,
    required this.year,
    required this.brand,
    this.isRefreshing = false,
    this.refreshFailure,
    this.failedRequest,
  });

  /// Lista completa de grupos de modelo.
  final List<ModelGroupEntity> groups;

  /// Cantidad de grupos visibles hasta ahora.
  final int visibleCount;

  /// Año de la lista que se está mostrando.
  final int year;

  /// Marca de la lista que se está mostrando.
  final String brand;

  /// Verdadero mientras se pide una lista nueva de la misma marca.
  final bool isRefreshing;

  /// Fallo del último refresco; nulo si no hubo fallo.
  final AppFailure? refreshFailure;

  /// Consulta que falló en el último refresco; nula si no hubo fallo.
  final ModelsRequest? failedRequest;

  ModelsLoaded copyWith({int? visibleCount}) => ModelsLoaded(
    groups: groups,
    visibleCount: visibleCount ?? this.visibleCount,
    year: year,
    brand: brand,
    isRefreshing: isRefreshing,
    refreshFailure: refreshFailure,
    failedRequest: failedRequest,
  );

  /// Mismo contenido, refrescando y sin el fallo anterior.
  ModelsLoaded refreshing() => ModelsLoaded(
    groups: groups,
    visibleCount: visibleCount,
    year: year,
    brand: brand,
    isRefreshing: true,
  );

  /// Mismo contenido y año visibles, con el fallo de la consulta pedida.
  ModelsLoaded failedRefresh(ModelsRequest request, AppFailure failure) =>
      ModelsLoaded(
        groups: groups,
        visibleCount: visibleCount,
        year: year,
        brand: brand,
        refreshFailure: failure,
        failedRequest: request,
      );

  @override
  List<Object?> get props => [
    groups,
    visibleCount,
    year,
    brand,
    isRefreshing,
    refreshFailure,
    failedRequest,
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
