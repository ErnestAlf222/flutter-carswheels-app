import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/features/vehicle_specs/domain/domain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/models/group_options_cache_model.dart';

/// Caché de versiones por variante guardada en Isar.
class IsarGroupOptionsCacheDatasource implements GroupOptionsCacheDatasource {
  const IsarGroupOptionsCacheDatasource(this.isar);

  final Isar isar;

  @override
  Future<List<VehicleOptionEntity>?> read(String key) async {
    final model = await isar.groupOptionsCacheModels.getByKey(key);
    if (model == null || model.optionIds.length != model.optionTexts.length) {
      return null;
    }
    return [
      for (final (index, id) in model.optionIds.indexed)
        VehicleOptionEntity(id: id, text: model.optionTexts[index]),
    ];
  }

  @override
  Future<void> write(String key, List<VehicleOptionEntity> options) {
    final model = GroupOptionsCacheModel(
      key: key,
      optionIds: [for (final option in options) option.id],
      optionTexts: [for (final option in options) option.text],
      savedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    return isar.writeTxn(() => isar.groupOptionsCacheModels.putByKey(model));
  }
}
