import 'package:cars_wheels_app/features/safety/domain/entities/group_safety_entity.dart';

/// Estrellas de un grupo de versiones.
abstract class SafetyRatingsRepository {
  /// Nulo si el modelo no se empareja con NHTSA.
  Future<GroupSafetyEntity?> getGroupSafety(
    int year,
    String make,
    String model,
  );
}
