import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/vehicle_specs/domain/domain.dart';

/// Estado del resumen de un grupo de modelos.
sealed class SummarySlot extends Equatable {
  const SummarySlot();

  @override
  List<Object?> get props => [];
}

/// El resumen se está calculando.
class SummaryLoading extends SummarySlot {
  const SummaryLoading();
}

/// Se obtuvo el resumen.
class SummaryFound extends SummarySlot {
  const SummaryFound(this.summary);

  final GroupSummaryEntity summary;

  @override
  List<Object?> get props => [summary];
}

/// No hay datos para el grupo.
class SummaryMissing extends SummarySlot {
  const SummaryMissing();
}

/// El cálculo falló o se canceló; se puede pedir de nuevo.
class SummaryFailed extends SummarySlot {
  const SummaryFailed();
}
