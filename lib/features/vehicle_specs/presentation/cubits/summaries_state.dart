import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/presentation/cubits/summary_slot.dart';

/// Resúmenes de los grupos por clave de resumen.
class SummariesState extends Equatable {
  const SummariesState({this.slots = const {}});

  final Map<String, SummarySlot> slots;

  /// Copia con los espacios dados reemplazando a los de su clave.
  SummariesState withSlots(Map<String, SummarySlot> changes) =>
      SummariesState(slots: {...slots, ...changes});

  /// Texto del consumo de la clave; nulo si no hay rango de km/l.
  String? consumptionLabelFor(String key) {
    final slot = slots[key];
    if (slot is! SummaryFound) return null;
    final min = slot.summary.minKmPerLiter;
    final max = slot.summary.maxKmPerLiter;
    if (min == null || max == null) return null;
    final figure = AppTexts.consumptionFigureLabel(min.round(), max.round());
    return '$figure ${AppTexts.consumptionUnitLabel}';
  }

  @override
  List<Object?> get props => [slots];
}
