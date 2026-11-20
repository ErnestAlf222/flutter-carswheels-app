/// En qué punto está la conexión a internet.
enum ConnectionPhase {
  /// Hay conexión o todavía no se sabe de ninguna falla.
  online,

  /// Las peticiones fallan por red: se muestra lo guardado.
  offline,

  /// Acaba de volver la conexión; el aviso dura poco.
  restored,
}
