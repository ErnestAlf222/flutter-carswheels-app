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
  });

  final int year;
  final List<BrandEntity> brands;

  /// Años disponibles en orden descendente.
  final List<int> availableYears;

  /// Índice de la marca seleccionada.
  final int selectedIndex;

  /// Índice de la primera marca visible en el carrusel.
  final int windowStart;

  CatalogLoaded copyWith({int? selectedIndex, int? windowStart}) =>
      CatalogLoaded(
        year: year,
        brands: brands,
        availableYears: availableYears,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        windowStart: windowStart ?? this.windowStart,
      );

  @override
  List<Object?> get props => [
    year,
    brands,
    availableYears,
    selectedIndex,
    windowStart,
  ];
}

class CatalogError extends CatalogState {
  const CatalogError(this.failure, {this.failedYear});

  final AppFailure failure;

  /// Año que falló; nulo si falló la carga inicial.
  final int? failedYear;

  @override
  List<Object?> get props => [failure, failedYear];
}
