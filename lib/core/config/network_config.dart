/// Límites de red.
class NetworkConfig {
  const NetworkConfig._();

  static const String jsonAcceptHeaderValue = 'application/json';
  static const int maxConcurrentRequests = 10;
  static const int commonsMinIntervalMilliseconds = 300;
  // Los dos tiempos de espera son provisionales.
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 20;
}
