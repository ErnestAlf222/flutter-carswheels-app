import 'package:cars_wheels_app/features/mexico_catalog/domain/repositories/mexico_catalog_repository.dart';

/// Obtiene los años disponibles del catálogo de México.
class GetMxYearsUseCase {
  const GetMxYearsUseCase(this.repository);

  final MexicoCatalogRepository repository;

  Future<List<int>> call() => repository.fetchYears();
}
