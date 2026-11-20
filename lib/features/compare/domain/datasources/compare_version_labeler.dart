import 'package:cars_wheels_app/features/compare/domain/entities/compare_slot_entity.dart';

/// Nombre legible de la versión guardada en un espacio; lo resuelve la capa app.
///
/// Usa la misma lógica de etiquetado que el selector de versión de Detalle.
abstract class CompareVersionLabeler {
  /// Nula si el espacio no tiene versión elegida o ya no se puede resolver;
  /// lanza si el catálogo no se pudo cargar.
  Future<String?> labelOf(CompareSlotEntity slot);
}
