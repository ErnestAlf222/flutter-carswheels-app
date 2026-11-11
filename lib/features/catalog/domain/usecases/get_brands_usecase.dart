import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/entities/brand_entity.dart';
import 'package:cars_wheels_app/features/catalog/domain/repositories/catalog_repository.dart';

/// Obtiene las marcas de un año, ordenadas sin distinguir mayúsculas ni acentos.
class GetBrandsUseCase {
  const GetBrandsUseCase({
    required this.repository,
    required this.sortStrategy,
  });

  final CatalogRepository repository;
  final SortStrategy<BrandEntity> sortStrategy;

  Future<List<BrandEntity>> call(int year) async {
    final brands = await repository.fetchBrands(year);
    return sortStrategy.sort(
      brands,
      (a, b) =>
          TextNormalizer.normalize(a.name)
              .compareTo(TextNormalizer.normalize(b.name)),
    );
  }
}
