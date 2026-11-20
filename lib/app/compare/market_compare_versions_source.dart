import 'package:cars_wheels_app/app/compare/compare_group_details_loader.dart';
import 'package:cars_wheels_app/app/compare/compare_version_labeler.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';

/// Versiones elegibles de un modelo, con los casos de uso de Detalle y el catálogo.
class MarketCompareVersionsSource implements CompareVersionsSource {
  const MarketCompareVersionsSource({
    required this.loader,
    required this.versionLabeler,
  });

  final CompareGroupDetailsLoader loader;
  final CompareVersionLabeler versionLabeler;

  @override
  Future<List<CompareVersionOptionEntity>> versionsOf(
    CompareSlotEntity slot,
  ) async {
    final details = await loader.load(slot);
    if (details == null) return const [];
    return [
      for (final version in details.versions) versionLabeler.optionOf(version),
    ];
  }
}
