import 'package:cars_wheels_app/features/compare/domain/entities/compare_slot_entity.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_vehicle_detail_entity.dart';

/// Datos comparables de un vehículo elegido; los resuelve la capa app.
abstract class CompareVehicleSource {
  /// Lanza si no se pudo cargar; nulo si el vehículo no tiene versiones.
  /// Nunca inventa valores.
  Future<CompareVehicleDetailEntity?> detailOf(CompareSlotEntity slot);
}
