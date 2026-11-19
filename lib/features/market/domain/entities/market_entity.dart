import 'package:cars_wheels_app/core/core.dart';

/// Mercado del que sale el catálogo.
enum Market {
  unitedStates(MarketConfig.unitedStatesCode, MarketConfig.unitedStatesFlag),
  mexico(MarketConfig.mexicoCode, MarketConfig.mexicoFlag);

  const Market(this.code, this.flag);

  /// Código guardado en disco.
  final String code;

  /// Emoji de la bandera del mercado.
  final String flag;

  /// El otro mercado: el selector alterna entre los dos.
  Market get other => this == unitedStates ? mexico : unitedStates;

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
