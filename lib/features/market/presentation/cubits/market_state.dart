import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/market/domain/entities/market_entity.dart';

/// Mercado actual y si ya se leyó el guardado en disco.
class MarketState extends Equatable {
  const MarketState({required this.market, this.isRestored = false});

  final Market market;

  /// Falso hasta que termina de leerse la preferencia guardada.
  final bool isRestored;

  @override
  List<Object?> get props => [market, isRestored];
}
