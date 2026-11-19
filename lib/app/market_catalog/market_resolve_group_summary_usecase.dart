import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Resumen de un grupo según el mercado; el de México se arma con sus versiones.
class MarketResolveGroupSummaryUseCase extends ResolveGroupSummaryUseCase {
  MarketResolveGroupSummaryUseCase({
    required this.unitedStates,
    required this.getMxVersions,
    required this.summaryBuilder,
    required this.currentMarket,
  }) : super(
         cache: unitedStates.cache,
         getGroupSummary: unitedStates.getGroupSummary,
         keyBuilder: unitedStates.keyBuilder,
         clock: unitedStates.clock,
       );

  final ResolveGroupSummaryUseCase unitedStates;
  final GetMxVersionsUseCase getMxVersions;
  final MxGroupSummaryBuilder summaryBuilder;
  final Market Function() currentMarket;

  @override
  Future<GroupSummaryEntity?> call({
    required int year,
    required String brand,
    required String groupName,
    required List<String> variantNames,
  }) async {
    if (currentMarket() != Market.mexico) {
      return unitedStates(
        year: year,
        brand: brand,
        groupName: groupName,
        variantNames: variantNames,
      );
    }
    // El catálogo del año ya está en memoria o en Isar: no hay otra caché aquí.
    return summaryBuilder.build(await getMxVersions(year, brand, groupName));
  }
}
