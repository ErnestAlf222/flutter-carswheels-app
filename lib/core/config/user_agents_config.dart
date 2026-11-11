/// Identificadores User-Agent para cada API externa.
class UserAgentsConfig {
  const UserAgentsConfig._();

  // EJEMPLO: se reemplaza por el contacto real antes del día 3.
  static const String contactInfo =
      'https://example.com/appautos; mailto:contacto@example.com';
  static const String commonsUserAgent = 'AppAutosPrueba/1.0 ($contactInfo)';
  static const String nhtsaUserAgent = commonsUserAgent;
  // CONUEE bloquea con 403 el identificador que lleva URL y mailto.
  static const String conueeUserAgent = 'AppAutosPrueba/1.0 (ernesto)';
  // Provisional: es el identificador que ya se probó con otras fuentes.
  static const String fuelEconomyUserAgent = 'AppAutosPrueba/1.0 (ernesto)';
}
