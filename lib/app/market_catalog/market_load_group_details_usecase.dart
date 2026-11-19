import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';

/// Versiones de un grupo según el mercado de los argumentos; México no usa la red.
class MarketLoadGroupDetailsUseCase extends LoadGroupDetailsUseCase {
  MarketLoadGroupDetailsUseCase({
    required this.unitedStates,
    required this.getMxVersions,
    required this.detailBuilder,
    required this.labelDisambiguator,
  }) : super(
         getGroupOptions: unitedStates.getGroupOptions,
         resolveVehicleDetail: unitedStates.resolveVehicleDetail,
         defaultVersionSelector: unitedStates.defaultVersionSelector,
       );

  final LoadGroupDetailsUseCase unitedStates;
  final GetMxVersionsUseCase getMxVersions;
  final MxVehicleDetailBuilder detailBuilder;
  final MxVersionLabelDisambiguator labelDisambiguator;

  @override
  Future<GroupDetailsEntity> call(DetailArgsEntity args) async {
    if (args.market != Market.mexico) return unitedStates(args);
    // El catálogo del año ya está en memoria o en Isar: no se pide otra vez.
    final mxVersions = await getMxVersions(
      args.year,
      args.brand,
      args.groupName,
    );
    if (mxVersions.isEmpty) {
      return const GroupDetailsEntity(versions: [], defaultIndex: 0);
    }
    final labels = labelDisambiguator.labelsFor(mxVersions);
    final versions = [
      for (final (index, version) in mxVersions.indexed)
        GroupVersionEntity(
          variantName: version.vehicle.rawModel,
          label: labels[index],
          detail: detailBuilder.build(version.vehicle, args.year),
        ),
    ];
    return GroupDetailsEntity(
      versions: versions,
      defaultIndex: defaultVersionSelector.selectIndex([
        for (final version in versions) version.detail,
      ]),
    );
  }
}
