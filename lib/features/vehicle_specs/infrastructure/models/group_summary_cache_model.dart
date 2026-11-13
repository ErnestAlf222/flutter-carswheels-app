import 'package:isar_community/isar.dart';

part 'group_summary_cache_model.g.dart';

/// Entrada de la caché de resúmenes de grupo guardada en Isar.
@collection
class GroupSummaryCacheModel {
  GroupSummaryCacheModel({
    required this.key,
    required this.vehicleClass,
    required this.minKmPerLiter,
    required this.maxKmPerLiter,
    required this.hasElectric,
    required this.hasPluginHybrid,
    required this.hasFuelCell,
    required this.variantCount,
    required this.savedAtMillis,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única: escribir una clave existente reemplaza la entrada.
  @Index(unique: true, replace: true)
  final String key;

  final String? vehicleClass;
  final double? minKmPerLiter;
  final double? maxKmPerLiter;
  final bool hasElectric;
  final bool hasPluginHybrid;
  final bool hasFuelCell;
  final int variantCount;
  final int savedAtMillis;
}
