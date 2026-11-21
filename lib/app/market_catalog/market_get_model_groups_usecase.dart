import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';

/// Grupos de modelo del mercado actual; en México salen de MxModelGrouper.
class MarketGetModelGroupsUseCase extends GetModelGroupsUseCase {
  MarketGetModelGroupsUseCase({
    required this.unitedStates,
    required this.getMxModelGroups,
    required this.currentMarket,
  }) : super(
         repository: unitedStates.repository,
         grouper: unitedStates.grouper,
       );

  final GetModelGroupsUseCase unitedStates;
  final GetMxModelGroupsUseCase getMxModelGroups;
  final Market Function() currentMarket;

  @override
  Future<List<ModelGroupEntity>> call(int year, String brand) =>
      _groupsOf(currentMarket(), year, brand);

  /// Los grupos del mercado pedido, sin tocar el mercado global de la app.
  @override
  Future<List<ModelGroupEntity>> inMarket(
    String marketCode,
    int year,
    String brand,
  ) => _groupsOf(Market.fromCode(marketCode) ?? currentMarket(), year, brand);

  Future<List<ModelGroupEntity>> _groupsOf(
    Market market,
    int year,
    String brand,
  ) async {
    if (market != Market.mexico) return unitedStates(year, brand);
    final groups = await getMxModelGroups(year, brand);
    return grouper.sortStrategy.sort([
      for (final group in groups)
        ModelGroupEntity(
          name: group.name,
          variants: [
            for (final version in group.versions)
              ModelEntity(name: version.vehicle.rawModel),
          ],
        ),
    ], (a, b) => TextNormalizer.compare(a.name, b.name));
  }
}
