import 'package:cars_wheels_app/core/core.dart';

/// Mercado del que sale el catálogo.
enum Market {
  unitedStates(MarketConfig.unitedStatesCode),
  mexico(MarketConfig.mexicoCode);

  const Market(this.code);

  /// Código guardado en disco.
  final String code;

  /// Mercado por defecto de la app.
  static Market get defaultMarket => fromCode(MarketConfig.defaultMarketCode)!;

  /// Mercado por código; nulo si no existe.
  static Market? fromCode(String? code) {
    for (final market in values) {
      if (market.code == code) return market;
    }
    return null;
  }
}
