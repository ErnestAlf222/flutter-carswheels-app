/// URLs base y User-Agent de las APIs externas.
class ApiConfig {
  const ApiConfig._();

  static const String fuelEconomyBaseUrl =
      'https://www.fueleconomy.gov/ws/rest/vehicle';
  static const String nhtsaVpicBaseUrl =
      'https://vpic.nhtsa.dot.gov/api/vehicles';
  static const String nhtsaApiBaseUrl = 'https://api.nhtsa.gov';
  static const String conueeApiBaseUrl =
      'https://www.datos.gob.mx/api/3/action';
  static const String conueeDatasetId =
      'catalogo_rendimiento_combustible_vehiculos_ligeros_venta_mexico';
  static const String commonsApiUrl = 'https://commons.wikimedia.org/w/api.php';
}

/// Identificadores User-Agent para cada API externa.
class UserAgentsConfig {
  const UserAgentsConfig._();

  static const String contactInfo =
      'https://github.com/ErnestAlf222/flutter-carswheels-app';
  static const String commonsUserAgent = 'CarsWheels/1.0 ($contactInfo)';
  static const String nhtsaUserAgent = commonsUserAgent;
  // CONUEE bloquea con 403 el identificador que lleva URL y mailto.
  static const String conueeUserAgent = 'AppAutosPrueba/1.0 (ernesto)';
  // Provisional: es el identificador que ya se probó con otras fuentes.
  static const String fuelEconomyUserAgent = 'AppAutosPrueba/1.0 (ernesto)';
  // Provisional: mismo identificador que las demás fuentes.
  static const String logosUserAgent = 'AppAutosPrueba/1.0 (ernesto)';
}
