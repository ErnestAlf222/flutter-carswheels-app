import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/group_summary_entity.dart';

/// Acceso al resumen de un grupo de modelos.
abstract class VehicleSpecsRepository {
  /// Nulo si ninguna variante tiene vehículo registrado.
  Future<GroupSummaryEntity?> getSummary(
    int year,
    String brand,
    List<String> variantNames,
  );

  /// Cancela las peticiones que aún no empezaron.
  Future<void> cancelPendingRequests();
}
