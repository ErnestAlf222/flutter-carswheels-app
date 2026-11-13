import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/group_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_detail_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_option_entity.dart';

/// Acceso al resumen de un grupo y al detalle de sus versiones.
abstract class VehicleSpecsRepository {
  /// Nulo si ninguna variante tiene vehículo registrado.
  Future<GroupSummaryEntity?> getSummary(
    int year,
    String brand,
    List<String> variantNames,
  );

  /// Versiones disponibles de un modelo, en el orden de la API.
  Future<List<VehicleOptionEntity>> getOptions(
    int year,
    String brand,
    String model,
  );

  /// Nulo si la API no devuelve registro para el id.
  Future<VehicleDetailEntity?> getDetail(
    int id, {
    required int year,
    required String brand,
    required String model,
  });

  /// Cancela las peticiones que aún no empezaron.
  Future<void> cancelPendingRequests();
}
