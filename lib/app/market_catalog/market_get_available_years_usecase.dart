import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';

/// Años del mercado actual: FuelEconomy para EE. UU. y package_show para México.
class MarketGetAvailableYearsUseCase extends GetAvailableYearsUseCase {
  const MarketGetAvailableYearsUseCase({
    required CatalogRepository repository,
    required this.unitedStates,
    required this.getMxYears,
    required this.currentMarket,
  }) : super(repository);

  final GetAvailableYearsUseCase unitedStates;
  final GetMxYearsUseCase getMxYears;
  final Market Function() currentMarket;

  @override
  Future<List<int>> call() async {
    if (currentMarket() != Market.mexico) return unitedStates();
    final years = await getMxYears();
    if (years.isEmpty) {
      throw const ParsingFailure(ConueeConfig.emptyYearsMessage);
    }
    return years.toSet().toList()..sort((a, b) => b.compareTo(a));
  }
}
