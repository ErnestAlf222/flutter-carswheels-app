/// Sonda ligera para saber si ya hay conexión; la implementa la capa de datos.
abstract class ConnectionProbe {
  /// Verdadero si el servidor respondió; falso si no se pudo conectar.
  Future<bool> isReachable();
}
