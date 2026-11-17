import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/safety/domain/entities/recall_entity.dart';

/// Recalls de un grupo: la cantidad y la lista.
class RecallSummaryEntity extends Equatable {
  const RecallSummaryEntity({required this.recalls});

  final List<RecallEntity> recalls;

  int get count => recalls.length;

  @override
  List<Object?> get props => [recalls];
}
