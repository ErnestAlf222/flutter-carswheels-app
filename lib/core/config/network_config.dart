/// Límites de red.
class NetworkConfig {
  const NetworkConfig._();

  static const String jsonAcceptHeaderValue = 'application/json';
  static const String imageAcceptHeaderValue = 'image/*';
  static const int maxConcurrentRequests = 10;
  static const int commonsMinIntervalMilliseconds = 300;
  // Los dos tiempos de espera son provisionales.
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 20;
}

/// Detección de conexión: sonda ligera, retroceso y avisos.
class ConnectivityConfig {
  const ConnectivityConfig._();

  // Fallas seguidas por tiempo de espera para dar por caída la conexión.
  static const int slowFailuresToGoOffline = 2;
  // Sonda HEAD sin cuerpo contra un host que la app ya usa.
  static const int probeTimeoutSeconds = 4;
  static const int probeInitialDelaySeconds = 5;
  static const int probeMaxDelaySeconds = 60;
  static const double probeBackoffFactor = 2.0;
  // Verificación al abrir una pantalla o volver a primer plano: una sonda como mucho cada tanto.
  static const int verifyMinIntervalSeconds = 30;
  // Cuánto dura "Conexión restablecida" antes de desaparecer.
  static const int restoredNoticeMilliseconds = 2500;
  // Tope de elementos que se reintentan al volver la conexión.
  static const int restoreMaxItems = 24;

  // Banda delgada bajo el encabezado.
  static const double bandVerticalPadding = 6.0;
  static const double bandIconSize = 16.0;
  static const double bandIconGap = 8.0;
  static const int bandAnimationMilliseconds = 220;
}
