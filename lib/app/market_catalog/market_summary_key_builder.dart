import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Clave de resumen con el mercado delante, para que no choquen entre mercados.
class MarketSummaryKeyBuilder extends SummaryKeyBuilder {
  const MarketSummaryKeyBuilder(this.currentMarket);

  final Market Function() currentMarket;

  @override
  String build({
    required String brand,
    required String groupName,
    required int year,
  }) {
    return [
      currentMarket().code,
      super.build(brand: brand, groupName: groupName, year: year),
    ].join(MarketConfig.keyScopeSeparator);
  }
}
