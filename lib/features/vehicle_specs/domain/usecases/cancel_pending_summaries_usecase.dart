import 'package:cars_wheels_app/features/vehicle_specs/domain/repositories/vehicle_specs_repository.dart';

/// Cancela las peticiones de resumen que aún no empezaron.
class CancelPendingSummariesUseCase {
  const CancelPendingSummariesUseCase(this.repository);

  final VehicleSpecsRepository repository;

  Future<void> call() => repository.cancelPendingRequests();
}
