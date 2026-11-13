import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/datasources/vehicle_specs_datasource.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/group_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_record_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/repositories/vehicle_specs_repository.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/services/group_summary_builder.dart';

// Resultado de leer una variante: su registro, o el fallo de red que lo impidió.
typedef _VariantRead = ({VehicleRecordEntity? record, NetworkFailure? failure});

/// Repositorio de resúmenes sobre un VehicleSpecsDatasource.
class VehicleSpecsRepositoryImpl implements VehicleSpecsRepository {
  const VehicleSpecsRepositoryImpl({
    required this.datasource,
    required this.queue,
    this.builder = const GroupSummaryBuilder(),
  });

  final VehicleSpecsDatasource datasource;

  /// Cola de FuelEconomy, para cancelar lo pendiente.
  final ConcurrencyLimitedQueue queue;
  final GroupSummaryBuilder builder;

  @override
  Future<GroupSummaryEntity?> getSummary(
    int year,
    String brand,
    List<String> variantNames,
  ) async {
    // Todas se lanzan a la vez; la cola limita la concurrencia real.
    final reads = await Future.wait([
      for (final name in variantNames) _readVariant(year, brand, name),
    ]);
    final records = [
      for (final read in reads)
        if (read.record != null) read.record!,
    ];
    if (records.isNotEmpty) return builder.build(records);
    final networkFailures = [
      for (final read in reads)
        if (read.failure != null) read.failure!,
    ];
    if (networkFailures.isNotEmpty) throw networkFailures.first;
    return null;
  }

  @override
  Future<void> cancelPendingRequests() async => queue.cancelPending();

  // Lee una variante; omite los fallos salvo la cancelación, que se relanza.
  Future<_VariantRead> _readVariant(
    int year,
    String brand,
    String variantName,
  ) async {
    try {
      final ids = await datasource.fetchOptionIds(year, brand, variantName);
      if (ids.isEmpty) return (record: null, failure: null);
      // La primera opción en el orden de la API es la versión de referencia.
      final record = await datasource.fetchVehicle(ids.first);
      return (record: record, failure: null);
    } on CancelledFailure {
      rethrow;
    } on NetworkFailure catch (failure) {
      return (record: null, failure: failure);
    } on AppFailure {
      return (record: null, failure: null);
    }
  }
}
