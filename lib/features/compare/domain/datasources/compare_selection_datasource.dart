import 'package:cars_wheels_app/features/compare/domain/entities/compare_slot_entity.dart';

/// Guarda la selección del comparador, una lista por mercado.
abstract class CompareSelectionDatasource {
  /// Vehículos guardados del mercado; vacío si no hay o no se pueden leer.
  Future<List<CompareSlotEntity>> read(String marketCode);

  /// Reemplaza la lista del mercado.
  Future<void> write(String marketCode, List<CompareSlotEntity> slots);

  /// Emite la lista del mercado ahora y cada vez que cambia.
  Stream<List<CompareSlotEntity>> watch(String marketCode);
}
