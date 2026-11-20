import 'package:cars_wheels_app/app/compare/compare_group_details_loader.dart';
import 'package:cars_wheels_app/app/compare/compare_version_namer.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';

/// Versiones elegibles de un modelo, con los casos de uso de Detalle y el catálogo.
class MarketCompareVersionsSource implements CompareVersionsSource {
  const MarketCompareVersionsSource({
    required this.loader,
    required this.versionNamer,
  });

  final CompareGroupDetailsLoader loader;
  final CompareVersionNamer versionNamer;

  @override
  Future<List<CompareVersionOptionEntity>> versionsOf(
    CompareSlotEntity slot,
  ) async {
    final details = await loader.load(slot);
    if (details == null) return const [];
    return [
      // La predeterminada sigue la regla de Detalle: su índice por defecto.
      for (final (index, version) in details.versions.indexed)
        versionNamer.optionOf(
          version,
          isDefault: index == details.defaultIndex,
        ),
    ];
  }
}
