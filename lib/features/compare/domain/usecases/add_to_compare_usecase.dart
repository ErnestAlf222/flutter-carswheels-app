import 'package:cars_wheels_app/features/compare/domain/datasources/compare_selection_datasource.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_add_result_entity.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_selection_entity.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_slot_entity.dart';

/// Agrega un vehículo al final de la selección de su mercado.
class AddToCompareUseCase {
  const AddToCompareUseCase(this.datasource);

  final CompareSelectionDatasource datasource;

  /// Rechaza duplicados y una lista llena sin tocar lo guardado.
  Future<CompareAddResult> call(CompareSlotEntity slot) async {
    final current = CompareSelectionEntity(
      await datasource.read(slot.marketCode),
    );
    if (current.contains(slot)) return CompareAlreadyPresent(current);
    if (current.isFull) return CompareFull(current);
    final next = CompareSelectionEntity([...current.slots, slot]);
    await datasource.write(slot.marketCode, next.slots);
    return CompareAdded(next);
  }
}
