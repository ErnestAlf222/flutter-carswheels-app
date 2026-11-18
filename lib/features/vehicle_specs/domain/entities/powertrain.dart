/// Tipo de motorización de un modelo.
enum Powertrain { combustion, electric, pluginHybrid, fuelCell, other }

/// Tipo de motorización para la insignia; el orden es la prioridad (electrificados primero).
enum EngineKind {
  electric,
  pluginHybrid,
  hybrid,
  hydrogen,
  diesel,
  gasoline,
  flexFuel;

  /// Tipo por nombre del enum; nulo si no existe.
  static EngineKind? fromName(String name) {
    for (final kind in values) {
      if (kind.name == name) return kind;
    }
    return null;
  }
}
