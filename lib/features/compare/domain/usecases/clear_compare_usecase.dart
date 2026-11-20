import 'package:cars_wheels_app/features/compare/domain/datasources/compare_selection_datasource.dart';

/// Vacía la selección de un mercado.
class ClearCompareUseCase {
  const ClearCompareUseCase(this.datasource);

  final CompareSelectionDatasource datasource;

  Future<void> call(String marketCode) =>
      datasource.write(marketCode, const []);
}
