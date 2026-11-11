import 'package:cars_wheels_app/features/catalog/domain/usecases/get_available_years_usecase.dart';

/// Obtiene el año más reciente disponible.
class GetLatestYearUseCase {
  const GetLatestYearUseCase(this._getAvailableYears);

  final GetAvailableYearsUseCase _getAvailableYears;

  /// Lanza ParsingFailure si no hay años.
  Future<int> call() async => (await _getAvailableYears()).first;
}
