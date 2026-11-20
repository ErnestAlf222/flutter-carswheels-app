import 'package:cars_wheels_app/app/compare/compare_group_details_loader.dart';
import 'package:cars_wheels_app/app/compare/compare_version_namer.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';

/// Nombre legible de la versión guardada, con la misma lógica de Detalle y el catálogo.
class MarketCompareVersionLabeler implements CompareVersionLabeler {
  const MarketCompareVersionLabeler({
    required this.loader,
    required this.namer,
  });

  final CompareGroupDetailsLoader loader;
  final CompareVersionNamer namer;

  @override
  Future<String?> labelOf(CompareSlotEntity slot) async {
    final key = slot.versionKey;
    if (key == null) return null;
    final details = await loader.load(slot);
    final version = details?.versions
        .where((candidate) => candidate.variantName == key)
        .firstOrNull;
    return version == null ? null : namer.labelOf(version);
  }
}
