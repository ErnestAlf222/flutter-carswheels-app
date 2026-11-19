import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// Origen del índice de búsqueda: usa el mercado del alcance, no el vigente,
/// para que cambiar de mercado a mitad de la construcción no mezcle datos.
class MarketSearchCatalogSource implements SearchCatalogSource {
  const MarketSearchCatalogSource({
    required this.unitedStatesBrands,
    required this.unitedStatesGroups,
    required this.mexicoBrands,
    required this.mexicoGroups,
  });

  final GetBrandsUseCase unitedStatesBrands;
  final GetModelGroupsUseCase unitedStatesGroups;
  final GetMxBrandsUseCase mexicoBrands;
  final GetMxModelGroupsUseCase mexicoGroups;

  @override
  Future<List<String>> fetchBrands(SearchScopeEntity scope) async {
    if (Market.fromCode(scope.marketCode) == Market.mexico) {
      final brands = await mexicoBrands(scope.year);
      return [for (final brand in brands) brand.name];
    }
    final brands = await unitedStatesBrands(scope.year);
    return [for (final brand in brands) brand.name];
  }

  @override
  Future<List<String>> fetchGroupNames(
    SearchScopeEntity scope,
    String brand,
  ) async {
    if (Market.fromCode(scope.marketCode) == Market.mexico) {
      final groups = await mexicoGroups(scope.year, brand);
      return [for (final group in groups) group.name];
    }
    final groups = await unitedStatesGroups(scope.year, brand);
    return [for (final group in groups) group.name];
  }
}
