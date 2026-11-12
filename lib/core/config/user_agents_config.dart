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
