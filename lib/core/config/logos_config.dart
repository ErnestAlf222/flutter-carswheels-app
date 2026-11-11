/// Origen y convenciones de los logos de marcas.
class LogosConfig {
  const LogosConfig._();

  static const String logosBaseUrl =
      'https://cdn.jsdelivr.net/gh/vehiclespecs/brand-logos@main/';
  static const String manifestFileName = 'brands.json';
  static const String svgExtension = '.svg';
  static const String acceptHeaderValue = 'application/json';

  // Nombres de FuelEconomy que difieren del nombre del manifiesto.
  static const Map<String, String> brandAliases = {
    'McLaren Automotive': 'McLaren',
    'RUF Automobile': 'RUF',
    'Build Your Dreams': 'BYD',
    'Gmc': 'GMC',
    'Mg': 'MG',
    'Baic': 'BAIC',
    'Seat': 'SEAT',
    'Volkswagen Comerciales': 'Volkswagen',
  };
}
