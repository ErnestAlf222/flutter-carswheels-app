import 'package:isar_community/isar.dart';

part 'model_summary_cache_model.g.dart';

/// Entrada de la caché de resúmenes guardada en Isar.
@collection
class ModelSummaryCacheModel {
  ModelSummaryCacheModel({
    required this.key,
    required this.vehicleClass,
    required this.powertrain,
    required this.combinedKmPerLiter,
    required this.savedAtMillis,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única: escribir una clave existente reemplaza la entrada.
  @Index(unique: true, replace: true)
  final String key;

  final String? vehicleClass;

  /// Nombre del valor del enum Powertrain.
  final String powertrain;
  final double? combinedKmPerLiter;
  final int savedAtMillis;
}
