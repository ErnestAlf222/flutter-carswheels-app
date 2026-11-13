/// Patrones para interpretar el campo trany (transmisión) de FuelEconomy.
class TransmissionConfig {
  const TransmissionConfig._();

  // Valores reales: 'Manual 6-spd', 'Manual 4-spd Doubled'.
  static const String manualPrefixPattern = r'^manual';

  // Valores reales: 'Automatic 4-spd', 'Automatic (S8)'; 'Auto' por si llega abreviado.
  static const String automaticPrefixPattern = r'^auto(matic)?';

  // CVT: 'Automatic (variable gear ratios)' o un código AV como 'Automatic (AV-S10)'.
  static const String cvtKeyword = 'variable gear ratios';
  static const String cvtCodePattern = r'\(AV-';

  // Cantidad de velocidades con guion: 'Automatic 4-spd', 'Manual 6-spd'.
  static const String speedsWithDashPattern = r'(\d+)-spd';

  // Cantidad de velocidades en código: '(S8)', '(A1)', '(L4)', '(AM7)', '(AM-S7)', '(AV-S10)'.
  static const String speedsCodePattern =
      r'\((?:[A-Z]{1,2}-)?[A-Z]{1,2}(\d+)\)';
}
