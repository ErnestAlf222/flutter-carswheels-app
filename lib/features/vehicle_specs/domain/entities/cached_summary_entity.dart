import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/model_summary_entity.dart';

/// Resumen guardado junto con el momento en que se guardó.
class CachedSummaryEntity extends Equatable {
  const CachedSummaryEntity({required this.summary, required this.savedAt});

  final ModelSummaryEntity summary;
  final DateTime savedAt;

  @override
  List<Object?> get props => [summary, savedAt];
}
