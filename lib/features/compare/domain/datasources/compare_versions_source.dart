import 'package:cars_wheels_app/features/compare/domain/entities/compare_slot_entity.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_version_option_entity.dart';

/// Versiones disponibles de un modelo; las resuelve la capa app.
abstract class CompareVersionsSource {
  /// Lista vacía si el modelo no tiene versiones; lanza si no se pudo cargar.
  Future<List<CompareVersionOptionEntity>> versionsOf(CompareSlotEntity slot);
}
