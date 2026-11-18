import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_year_source_entity.dart';

/// Lista de años guardada junto con el momento en que se guardó.
class CachedMxYearsEntity extends Equatable {
  const CachedMxYearsEntity({required this.sources, required this.savedAt});

  final List<MxYearSourceEntity> sources;
  final DateTime savedAt;

  @override
  List<Object?> get props => [sources, savedAt];
}
