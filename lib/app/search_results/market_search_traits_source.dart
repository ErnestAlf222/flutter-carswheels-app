import 'package:cars_wheels_app/features/search/search.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Rasgos de un resultado a partir de su resumen de grupo.
///
/// Usa el mismo caso de uso que las tarjetas (y por tanto la misma caché de
/// resúmenes): lo que una tarjeta ya cargó se lee de la caché, sin red.
class MarketSearchTraitsSource implements SearchTraitsSource {
  const MarketSearchTraitsSource(this.resolveGroupSummary);

  final ResolveGroupSummaryUseCase resolveGroupSummary;

  @override
  Future<SearchResultTraitsEntity> traitsOf(SearchResultEntity result) async {
    final groupName = result.groupName;
    if (groupName == null) return SearchResultTraitsEntity.unknown;
    final summary = await resolveGroupSummary(
      year: result.year,
      brand: result.brand,
      groupName: groupName,
      variantNames: result.variantNames,
    );
    return summary == null
        ? SearchResultTraitsEntity.unknown
        : traitsOfSummary(summary);
  }

  /// Mapea la motorización del resumen a las opciones del filtro. El hidrógeno
  /// no tiene opción propia y un resumen sin tipos no entra a ninguna.
  static SearchResultTraitsEntity traitsOfSummary(GroupSummaryEntity summary) {
    final engines = <SearchEngineOption>{};
    for (final kind in summary.engineKinds) {
      final option = _optionOf(kind);
      if (option != null) engines.add(option);
    }
    // Resúmenes guardados antes de existir los tipos: solo las banderas.
    if (summary.engineKinds.isEmpty) {
      if (summary.hasElectric) engines.add(SearchEngineOption.electric);
      if (summary.hasPluginHybrid) engines.add(SearchEngineOption.pluginHybrid);
    }
    return SearchResultTraitsEntity(
      engines: engines,
      maxKmPerLiter: summary.maxKmPerLiter,
    );
  }

  static SearchEngineOption? _optionOf(EngineKind kind) => switch (kind) {
    EngineKind.electric => SearchEngineOption.electric,
    EngineKind.hybrid => SearchEngineOption.hybrid,
    EngineKind.pluginHybrid => SearchEngineOption.pluginHybrid,
    EngineKind.gasoline ||
    EngineKind.diesel ||
    EngineKind.flexFuel => SearchEngineOption.combustion,
    EngineKind.hydrogen => null,
  };
}
