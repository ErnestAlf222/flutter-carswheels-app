import 'package:cars_wheels_app/features/catalog/domain/entities/model_group_entity.dart';
import 'package:cars_wheels_app/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:cars_wheels_app/features/catalog/domain/services/model_grouper.dart';

/// Obtiene los modelos de una marca y año agrupados por modelo.
class GetModelGroupsUseCase {
  const GetModelGroupsUseCase({
    required this.repository,
    required this.grouper,
  });

  final CatalogRepository repository;
  final ModelGrouper grouper;

  Future<List<ModelGroupEntity>> call(int year, String brand) async {
    final models = await repository.fetchModels(year, brand);
    return grouper.group(brand, models);
  }
}
