import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/cached_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/group_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/models/group_summary_cache_model.dart';

/// Convierte entre la entrada guardada en Isar y la entidad de caché.
class CachedSummaryMapper {
  const CachedSummaryMapper._();

  static CachedSummaryEntity toEntity(GroupSummaryCacheModel model) {
    return CachedSummaryEntity(
      summary: GroupSummaryEntity(
        vehicleClass: model.vehicleClass,
        minKmPerLiter: model.minKmPerLiter,
        maxKmPerLiter: model.maxKmPerLiter,
        hasElectric: model.hasElectric,
        hasPluginHybrid: model.hasPluginHybrid,
        hasFuelCell: model.hasFuelCell,
        variantCount: model.variantCount,
      ),
      savedAt: DateTime.fromMillisecondsSinceEpoch(model.savedAtMillis),
    );
  }

  static GroupSummaryCacheModel toModel(
    String key,
    CachedSummaryEntity entity,
  ) {
    final summary = entity.summary;
    return GroupSummaryCacheModel(
      key: key,
      vehicleClass: summary.vehicleClass,
      minKmPerLiter: summary.minKmPerLiter,
      maxKmPerLiter: summary.maxKmPerLiter,
      hasElectric: summary.hasElectric,
      hasPluginHybrid: summary.hasPluginHybrid,
      hasFuelCell: summary.hasFuelCell,
      variantCount: summary.variantCount,
      savedAtMillis: entity.savedAt.millisecondsSinceEpoch,
    );
  }
}
