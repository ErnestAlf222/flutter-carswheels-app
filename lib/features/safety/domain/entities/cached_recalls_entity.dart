import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/safety/domain/entities/recall_summary_entity.dart';

/// Recalls de un grupo guardados con el momento en que se guardaron.
class CachedRecallsEntity extends Equatable {
  const CachedRecallsEntity({required this.summary, required this.savedAt});

  final RecallSummaryEntity summary;
  final DateTime savedAt;

  @override
  List<Object?> get props => [summary, savedAt];
}
