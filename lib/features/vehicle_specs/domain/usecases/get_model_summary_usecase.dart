import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/model_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/repositories/vehicle_specs_repository.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/services/representative_variant_selector.dart';

/// Pide a la red el resumen de la variante representativa de un grupo.
class GetModelSummaryUseCase {
  const GetModelSummaryUseCase({
    required this.repository,
    required this.selector,
  });

  final VehicleSpecsRepository repository;
  final RepresentativeVariantSelector selector;

  Future<ModelSummaryEntity?> call({
    required int year,
    required String brand,
    required List<String> variantNames,
  }) {
    return repository.getSummary(year, brand, selector.select(variantNames));
  }
}
