import 'package:cars_wheels_app/features/compare/domain/datasources/compare_selection_datasource.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_slot_entity.dart';

/// Quita un vehículo de la selección de su mercado, conservando el orden.
class RemoveFromCompareUseCase {
  const RemoveFromCompareUseCase(this.datasource);

  final CompareSelectionDatasource datasource;

  Future<void> call(CompareSlotEntity slot) async {
    final current = await datasource.read(slot.marketCode);
    final next = [
      for (final item in current)
        if (item.identity != slot.identity) item,
    ];
    if (next.length == current.length) return;
    await datasource.write(slot.marketCode, next);
  }
}
