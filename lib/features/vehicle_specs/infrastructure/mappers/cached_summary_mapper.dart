import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/cached_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/model_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/powertrain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/models/model_summary_cache_model.dart';

/// Convierte entre la entrada guardada en Isar y la entidad de caché.
class CachedSummaryMapper {
  const CachedSummaryMapper._();

  static CachedSummaryEntity toEntity(ModelSummaryCacheModel model) {
    return CachedSummaryEntity(
      summary: ModelSummaryEntity(
        vehicleClass: model.vehicleClass,
        powertrain: Powertrain.values.firstWhere(
          (powertrain) => powertrain.name == model.powertrain,
          orElse: () => Powertrain.other,
        ),
        combinedKmPerLiter: model.combinedKmPerLiter,
      ),
      savedAt: DateTime.fromMillisecondsSinceEpoch(model.savedAtMillis),
    );
  }

  static ModelSummaryCacheModel toModel(
    String key,
    CachedSummaryEntity entity,
  ) {
    return ModelSummaryCacheModel(
      key: key,
      vehicleClass: entity.summary.vehicleClass,
      powertrain: entity.summary.powertrain.name,
      combinedKmPerLiter: entity.summary.combinedKmPerLiter,
      savedAtMillis: entity.savedAt.millisecondsSinceEpoch,
    );
  }
}
