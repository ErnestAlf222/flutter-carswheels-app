/// URLs base de las APIs externas.
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
