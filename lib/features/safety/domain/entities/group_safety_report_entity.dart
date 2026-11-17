import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/safety/domain/entities/group_safety_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/recall_summary_entity.dart';

/// Seguridad de un grupo; nulo significa sin dato, nunca cero.
class GroupSafetyReportEntity extends Equatable {
  const GroupSafetyReportEntity({this.safety, this.recalls});

  /// Nulo si el modelo no se emparejó con NHTSA.
  final GroupSafetyEntity? safety;

  /// Nulo si no se puede asegurar la lista (sin emparejar y sin recalls).
  final RecallSummaryEntity? recalls;

  @override
  List<Object?> get props => [safety, recalls];
}
