/// Resultado de reemplazar un vehículo de la selección por otro.
enum CompareReplaceResult {
  /// El vehículo nuevo ocupó la posición del anterior.
  replaced,

  /// El vehículo nuevo ya estaba en otra posición; no se tocó nada.
  alreadyPresent,

  /// El vehículo a reemplazar ya no estaba en la selección.
  notFound,
}
