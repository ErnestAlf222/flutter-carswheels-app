import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/entities/model_entity.dart';
import 'package:cars_wheels_app/features/catalog/domain/repositories/catalog_repository.dart';

/// Obtiene los modelos de una marca y año, ordenados y sin duplicados.
class GetModelsUseCase {
  const GetModelsUseCase({
    required this.repository,
    required this.sortStrategy,
  });

  final CatalogRepository repository;
  final SortStrategy<ModelEntity> sortStrategy;

  Future<List<ModelEntity>> call(int year, String brand) async {
    final models = await repository.fetchModels(year, brand);
    // Quita nombres idénticos sin agrupar ni cambiar ningún nombre.
    final uniqueModels = models.toSet().toList();
    return sortStrategy.sort(
      uniqueModels,
      (a, b) =>
          TextNormalizer.normalize(a.name)
              .compareTo(TextNormalizer.normalize(b.name)),
    );
  }
}
