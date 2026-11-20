import 'package:cars_wheels_app/features/compare/domain/datasources/compare_selection_datasource.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_selection_entity.dart';

/// Observa la selección de un mercado: la actual y cada cambio.
class ObserveCompareSelectionUseCase {
  const ObserveCompareSelectionUseCase(this.datasource);

  final CompareSelectionDatasource datasource;

  Stream<CompareSelectionEntity> call(String marketCode) =>
      datasource.watch(marketCode).map(CompareSelectionEntity.new);
}
