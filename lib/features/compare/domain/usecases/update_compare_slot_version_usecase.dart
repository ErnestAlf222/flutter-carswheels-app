import 'package:cars_wheels_app/features/compare/domain/datasources/compare_selection_datasource.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_slot_entity.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_version_update_result.dart';

/// Cambia la versión de un vehículo de la selección, conservando su posición.
class UpdateCompareSlotVersionUseCase {
  const UpdateCompareSlotVersionUseCase(this.datasource);

  final CompareSelectionDatasource datasource;

  /// [versionKey] nulo vuelve a la versión predeterminada.
  Future<CompareVersionUpdateResult> call(
    CompareSlotEntity slot,
    String? versionKey,
  ) async {
    final current = await datasource.read(slot.marketCode);
    final index = current.indexWhere((item) => item.identity == slot.identity);
    if (index < 0 || current[index].versionKey == versionKey) {
      return CompareVersionUpdateResult.unchanged;
    }
    final changed = current[index].withVersion(versionKey);
    final repeated = current.any((item) => item.identity == changed.identity);
    if (repeated) return CompareVersionUpdateResult.duplicate;
    await datasource.write(slot.marketCode, [
      for (final (position, item) in current.indexed)
        position == index ? changed : item,
    ]);
    return CompareVersionUpdateResult.updated;
  }
}
