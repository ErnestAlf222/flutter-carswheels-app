import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_year_catalog_entity.dart';

/// Año guardado junto con el momento en que se guardó.
class CachedMxYearEntity extends Equatable {
  const CachedMxYearEntity({required this.catalog, required this.savedAt});

  final MxYearCatalogEntity catalog;
  final DateTime savedAt;

  @override
  List<Object?> get props => [catalog, savedAt];
}
