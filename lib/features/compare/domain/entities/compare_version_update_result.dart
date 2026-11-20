/// Resultado de cambiar la versión de un vehículo de la selección.
enum CompareVersionUpdateResult {
  /// La versión se guardó.
  updated,

  /// No había nada que cambiar: misma versión o el vehículo ya no está.
  unchanged,

  /// Otro vehículo de la lista ya es exactamente ese; no se cambió.
  duplicate,
}
