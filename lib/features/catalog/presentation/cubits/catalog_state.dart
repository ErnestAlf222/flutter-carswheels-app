import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';

/// Estado de la carga del catálogo.
sealed class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

class CatalogInitial extends CatalogState {
  const CatalogInitial();
}

class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

class CatalogLoaded extends CatalogState {
  const CatalogLoaded({
    required this.year,
    required this.brands,
    required this.availableYears,
    this.selectedIndex = 0,
    this.windowStart = 0,
    this.isRefreshing = false,
    this.failedYear,
    this.refreshFailure,
  });

  final int year;
  final List<BrandEntity> brands;

  /// Años disponibles en orden descendente.
  final List<int> availableYears;

  /// Índice de la marca seleccionada.
  final int selectedIndex;

  /// Índice de la primera marca visible en el carrusel.
  final int windowStart;

  /// Verdadero mientras se piden las marcas de otro año.
  final bool isRefreshing;

  /// Año cuyo cambio falló; nulo si no hubo fallo.
  final int? failedYear;

  /// Fallo del último cambio de año; nulo si no hubo fallo.
  final AppFailure? refreshFailure;

  CatalogLoaded copyWith({int? selectedIndex, int? windowStart}) =>
      CatalogLoaded(
        year: year,
        brands: brands,
        availableYears: availableYears,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        windowStart: windowStart ?? this.windowStart,
        isRefreshing: isRefreshing,
        failedYear: failedYear,
        refreshFailure: refreshFailure,
      );

  /// Mismo contenido, refrescando y sin el fallo anterior.
  CatalogLoaded refreshing() => CatalogLoaded(
    year: year,
    brands: brands,
    availableYears: availableYears,
    selectedIndex: selectedIndex,
    windowStart: windowStart,
    isRefreshing: true,
  );

  /// Mismo contenido, sin refrescar y con el fallo del año pedido.
  CatalogLoaded failedRefresh(int requestedYear, AppFailure failure) =>
      CatalogLoaded(
        year: year,
        brands: brands,
        availableYears: availableYears,
        selectedIndex: selectedIndex,
        windowStart: windowStart,
        failedYear: requestedYear,
        refreshFailure: failure,
      );

  @override
  List<Object?> get props => [
    year,
    brands,
    availableYears,
    selectedIndex,
    windowStart,
    isRefreshing,
    failedYear,
    refreshFailure,
  ];
}

/// Fallo de la carga inicial, cuando no hay contenido que mostrar.
class CatalogError extends CatalogState {
  const CatalogError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
