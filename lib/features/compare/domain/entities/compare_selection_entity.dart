import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/config/compare_config.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_slot_entity.dart';

/// Lista ordenada de vehículos por comparar, hasta [CompareConfig.maxSlots].
class CompareSelectionEntity extends Equatable {
  const CompareSelectionEntity(this.slots);

  /// Selección sin vehículos.
  static const CompareSelectionEntity empty = CompareSelectionEntity([]);

  final List<CompareSlotEntity> slots;

  int get length => slots.length;
  bool get isEmpty => slots.isEmpty;
  bool get isFull => slots.length >= CompareConfig.maxSlots;

  /// Hay suficientes vehículos para armar la comparación.
  bool get canCompare => slots.length >= CompareConfig.minSlots;

  bool contains(CompareSlotEntity slot) =>
      slots.any((item) => item.identity == slot.identity);

  @override
  List<Object?> get props => [slots];
}
