import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/repositories/catalog_repository.dart';

/// Obtiene los años disponibles, descendentes y sin repetir.
class GetAvailableYearsUseCase {
  const GetAvailableYearsUseCase(this._repository);

  final CatalogRepository _repository;

  /// Lanza ParsingFailure si no hay años.
  Future<List<int>> call() async {
    final years = await _repository.fetchYears();
    if (years.isEmpty) {
      throw const ParsingFailure('La lista de años está vacía');
    }
    return years.toSet().toList()..sort((a, b) => b.compareTo(a));
  }
}
