import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_version_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/usecases/get_mx_model_groups_usecase.dart';

/// Obtiene las versiones de un grupo de modelo de una marca y año.
class GetMxVersionsUseCase {
  const GetMxVersionsUseCase(this.getModelGroups);

  final GetMxModelGroupsUseCase getModelGroups;

  /// Lista vacía si el grupo no existe.
  Future<List<MxVersionEntity>> call(
    int year,
    String brand,
    String groupName,
  ) async {
    final groups = await getModelGroups(year, brand);
    final key = TextNormalizer.normalize(groupName);
    for (final group in groups) {
      if (TextNormalizer.normalize(group.name) == key) return group.versions;
    }
    return const [];
  }
}
