import 'package:cars_wheels_app/features/compare/domain/datasources/compare_selection_datasource.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_replace_result.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_slot_entity.dart';

/// Cambia un vehículo de la selección por otro, en la misma posición.
class ReplaceCompareSlotUseCase {
  const ReplaceCompareSlotUseCase(this.datasource);

  final CompareSelectionDatasource datasource;

  /// Rechaza un nuevo ya presente o un anterior ausente sin tocar lo guardado.
  Future<CompareReplaceResult> call(
    CompareSlotEntity current,
    CompareSlotEntity replacement,
  ) async {
    final saved = await datasource.read(current.marketCode);
    final index = saved.indexWhere((item) => item.identity == current.identity);
    if (index < 0) return CompareReplaceResult.notFound;
    final repeated = saved.any((item) => item.identity == replacement.identity);
    if (repeated) return CompareReplaceResult.alreadyPresent;
    await datasource.write(current.marketCode, [
      for (final (position, item) in saved.indexed)
        position == index ? replacement : item,
    ]);
    return CompareReplaceResult.replaced;
  }
}
