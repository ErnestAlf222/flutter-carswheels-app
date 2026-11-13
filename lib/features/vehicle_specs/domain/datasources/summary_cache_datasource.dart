import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/cached_summary_entity.dart';

/// Fuente de datos de la caché de resúmenes.
abstract class SummaryCacheDatasource {
  Future<CachedSummaryEntity?> read(String key);

  /// Reemplaza la entrada si la clave ya existe.
  Future<void> write(String key, CachedSummaryEntity entry);
}
