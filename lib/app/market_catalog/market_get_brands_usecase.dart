import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';

/// Marcas del mercado actual, con el mismo orden en los dos.
class MarketGetBrandsUseCase extends GetBrandsUseCase {
  MarketGetBrandsUseCase({
    required this.unitedStates,
    required this.getMxBrands,
    required this.currentMarket,
  }) : super(
         repository: unitedStates.repository,
         sortStrategy: unitedStates.sortStrategy,
       );

  final GetBrandsUseCase unitedStates;
  final GetMxBrandsUseCase getMxBrands;
  final Market Function() currentMarket;

  @override
  Future<List<BrandEntity>> call(int year) async {
    if (currentMarket() != Market.mexico) return unitedStates(year);
    final brands = await getMxBrands(year);
    return sortStrategy.sort(
      [for (final brand in brands) BrandEntity(name: brand.name)],
      (a, b) =>
          TextNormalizer.normalize(a.name)
              .compareTo(TextNormalizer.normalize(b.name)),
    );
  }
}
