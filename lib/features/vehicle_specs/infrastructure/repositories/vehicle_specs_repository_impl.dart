import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/datasources/vehicle_specs_datasource.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/model_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/repositories/vehicle_specs_repository.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/services/model_summary_builder.dart';

/// Repositorio de resúmenes sobre un VehicleSpecsDatasource.
class VehicleSpecsRepositoryImpl implements VehicleSpecsRepository {
  const VehicleSpecsRepositoryImpl({
    required this.datasource,
    required this.queue,
    this.builder = const ModelSummaryBuilder(),
  });

  final VehicleSpecsDatasource datasource;

  /// Cola de FuelEconomy, para cancelar lo pendiente.
  final ConcurrencyLimitedQueue queue;
  final ModelSummaryBuilder builder;

  @override
  Future<ModelSummaryEntity?> getSummary(
    int year,
    String brand,
    String modelName,
  ) async {
    final ids = await datasource.fetchOptionIds(year, brand, modelName);
    if (ids.isEmpty) return null;
    // La primera opción en el orden de la API es la versión de referencia.
    final record = await datasource.fetchVehicle(ids.first);
    return record == null ? null : builder.build(record);
  }

  @override
  Future<void> cancelPendingRequests() async => queue.cancelPending();
}
