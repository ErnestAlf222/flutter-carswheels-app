import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/model_summary_entity.dart';

/// Acceso al resumen de un modelo.
abstract class VehicleSpecsRepository {
  /// Nulo si el modelo no tiene vehículo registrado.
  Future<ModelSummaryEntity?> getSummary(
    int year,
    String brand,
    String modelName,
  );

  /// Cancela las peticiones que aún no empezaron.
  Future<void> cancelPendingRequests();
}
