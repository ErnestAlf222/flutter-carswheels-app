import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// Arma los argumentos de Detalle para un resultado de búsqueda.
class MarketSearchDetailArgsBuilder {
  const MarketSearchDetailArgsBuilder({
    required this.getModelGroups,
    required this.currentMarket,
  });

  final GetModelGroupsUseCase getModelGroups;
  final Market Function() currentMarket;

  /// Nulo si el resultado es solo una marca o ya no es del mercado vigente.
  Future<DetailArgsEntity?> build(SearchResultEntity result) async {
    final groupName = result.groupName;
    final market = Market.fromCode(result.marketCode);
    if (groupName == null || market == null || market != currentMarket()) {
      return null;
    }
    // Las variantes salen del mismo catálogo que ya se descargó al indexar.
    final groups = await getModelGroups(result.year, result.brand);
    final group = groups
        .where((candidate) => candidate.name == groupName)
        .firstOrNull;
    return DetailArgsEntity(
      brand: result.brand,
      groupName: groupName,
      year: result.year,
      variantNames: [
        for (final variant in group?.variants ?? const <ModelEntity>[])
          variant.name,
      ],
      photo: null,
      heroTag: [
        SearchConfig.detailHeroTagPrefix,
        market.code,
        result.year,
        result.brand,
        groupName,
      ].join(SearchConfig.scopeKeySeparator),
      market: market,
    );
  }
}
