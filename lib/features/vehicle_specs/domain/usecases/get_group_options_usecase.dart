import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/group_option_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_option_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/repositories/vehicle_specs_repository.dart';

// Resultado de leer una variante: sus opciones, o el fallo que lo impidió.
typedef _VariantOptions = ({
  List<VehicleOptionEntity>? options,
  AppFailure? failure,
});

/// Pide las opciones de todas las variantes de un grupo.
class GetGroupOptionsUseCase {
  const GetGroupOptionsUseCase(this.repository);

  final VehicleSpecsRepository repository;

  /// Orden de las variantes y, dentro de cada una, el de la API.
  /// Omite las variantes que fallan; si todas fallan por red, relanza el fallo.
  Future<List<GroupOptionEntity>> call({
    required int year,
    required String brand,
    required List<String> variantNames,
  }) async {
    // Todas se lanzan a la vez; la cola limita la concurrencia real.
    final reads = await Future.wait([
      for (final name in variantNames) _read(year, brand, name),
    ]);
    final failures = [
      for (final read in reads)
        if (read.failure != null) read.failure!,
    ];
    final allFailedByNetwork =
        reads.isNotEmpty &&
        failures.length == reads.length &&
        failures.every((failure) => failure is NetworkFailure);
    if (allFailedByNetwork) throw failures.first;
    return [
      for (final (index, read) in reads.indexed)
        for (final option in read.options ?? <VehicleOptionEntity>[])
          GroupOptionEntity(variantName: variantNames[index], option: option),
    ];
  }

  // Lee una variante; la cancelación se relanza y los demás fallos se guardan.
  Future<_VariantOptions> _read(int year, String brand, String name) async {
    try {
      final options = await repository.getOptions(year, brand, name);
      return (options: options, failure: null);
    } on CancelledFailure {
      rethrow;
    } on AppFailure catch (failure) {
      return (options: null, failure: failure);
    }
  }
}
