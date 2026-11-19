import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/features/market/domain/datasources/market_preference_datasource.dart';
import 'package:cars_wheels_app/features/market/domain/entities/market_entity.dart';
import 'package:cars_wheels_app/features/market/presentation/cubits/market_state.dart';

/// Expone el mercado actual, lo guarda al cambiarlo y lo restaura al abrir.
class MarketCubit extends Cubit<MarketState> {
  MarketCubit({required this.preference})
    : super(MarketState(market: Market.defaultMarket));

  final MarketPreferenceDatasource preference;

  /// Mercado vigente.
  Market get market => state.market;

  /// Lee el mercado guardado; sin dato o con error queda el de por defecto.
  Future<void> restore() async {
    final fallback = state.market;
    Market restored = fallback;
    try {
      restored = Market.fromCode(await preference.read()) ?? fallback;
    } on Object {
      // Una preferencia ilegible cuenta como ausente.
    }
    if (isClosed) return;
    emit(MarketState(market: restored, isRestored: true));
  }

  /// Cambia de mercado y lo guarda; ignora el que ya está activo.
  Future<void> select(Market market) async {
    if (market == state.market) return;
    emit(MarketState(market: market, isRestored: state.isRestored));
    try {
      await preference.write(market.code);
    } on Object {
      // Si no se pudo guardar, el cambio sigue valiendo en esta sesión.
    }
  }
}
