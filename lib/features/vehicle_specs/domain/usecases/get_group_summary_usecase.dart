import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/group_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/repositories/vehicle_specs_repository.dart';

/// Pide a la red el resumen de un grupo con todas sus variantes.
class GetGroupSummaryUseCase {
  const GetGroupSummaryUseCase(this.repository);

  final VehicleSpecsRepository repository;

  Future<GroupSummaryEntity?> call({
    required int year,
    required String brand,
    required List<String> variantNames,
  }) {
    return repository.getSummary(year, brand, variantNames);
  }
}
