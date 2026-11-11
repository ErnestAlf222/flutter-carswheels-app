import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/repositories/catalog_repository.dart';

/// Obtiene el año más reciente disponible.
class GetLatestYearUseCase {
  const GetLatestYearUseCase(this._repository);

  final CatalogRepository _repository;

  /// Lanza ParsingFailure si no hay años.
  Future<int> call() async {
    final years = await _repository.fetchYears();
    if (years.isEmpty) {
      throw const ParsingFailure('La lista de años está vacía');
    }
    return years.reduce((a, b) => a >= b ? a : b);
  }
}
