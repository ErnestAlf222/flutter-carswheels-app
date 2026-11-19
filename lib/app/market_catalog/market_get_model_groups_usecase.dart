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
  Future<List<ModelGroupEntity>> call(int year, String brand) async {
    if (currentMarket() != Market.mexico) return unitedStates(year, brand);
    final groups = await getMxModelGroups(year, brand);
    return grouper.sortStrategy.sort(
      [
        for (final group in groups)
          ModelGroupEntity(
            name: group.name,
            variants: [
              for (final version in group.versions)
                ModelEntity(name: version.vehicle.rawModel),
            ],
          ),
      ],
      (a, b) =>
          TextNormalizer.normalize(a.name)
              .compareTo(TextNormalizer.normalize(b.name)),
    );
  }
}
