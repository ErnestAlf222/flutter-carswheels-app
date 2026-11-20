import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/market/market.dart';

/// Mercado vigente del comparador, a partir de MarketCubit.
class MarketCompareMarketSource implements CompareMarketSource {
  const MarketCompareMarketSource(this.market);

  final MarketCubit market;

  @override
  String get marketCode => market.market.code;

  /// Solo los cambios reales de mercado, no cada estado nuevo del cubit.
  @override
  Stream<String> get marketChanges {
    final current = market.market.code;
    return market.stream
        .map((state) => state.market.code)
        .skipWhile((code) => code == current)
        .distinct();
  }
}
