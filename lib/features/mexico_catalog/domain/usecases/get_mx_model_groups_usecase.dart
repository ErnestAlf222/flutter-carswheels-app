import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_model_group_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/repositories/mexico_catalog_repository.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/services/mx_model_grouper.dart';

/// Obtiene los grupos de modelo de una marca y año.
class GetMxModelGroupsUseCase {
  const GetMxModelGroupsUseCase({
    required this.repository,
    required this.grouper,
  });

  final MexicoCatalogRepository repository;
  final MxModelGrouper grouper;

  Future<List<MxModelGroupEntity>> call(int year, String brand) async {
    final catalog = await repository.fetchYear(year);
    final brandKey = TextNormalizer.normalize(brand);
    final vehicles = [
      for (final vehicle in catalog.vehicles)
        if (TextNormalizer.normalize(vehicle.brand) == brandKey) vehicle,
    ];
    return grouper.group(brand, vehicles);
  }
}
