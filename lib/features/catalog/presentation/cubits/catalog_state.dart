import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/entities/brand_entity.dart';

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
  const CatalogLoaded({required this.year, required this.brands});

  final int year;
  final List<BrandEntity> brands;

  @override
  List<Object?> get props => [year, brands];
}

class CatalogError extends CatalogState {
  const CatalogError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
