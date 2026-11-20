import 'package:cars_wheels_app/features/compare/domain/entities/compare_slot_entity.dart';

/// Seguridad NHTSA de un vehículo elegido; la implementa la capa app.
abstract class CompareSafetySource {
  /// Estrellas generales; nulo si el mercado no tiene NHTSA o no hay calificación.
  /// Lanza si la consulta falla.
  Future<int?> overallStarsOf(CompareSlotEntity slot);
}
