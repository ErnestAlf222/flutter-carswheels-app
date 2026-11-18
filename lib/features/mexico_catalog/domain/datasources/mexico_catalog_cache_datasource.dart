import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/cached_mx_year_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/cached_mx_years_entity.dart';

/// Caché local del catálogo de México: lista de años y payload por año.
abstract class MexicoCatalogCacheDatasource {
  Future<CachedMxYearsEntity?> readYears(String key);

  /// Reemplaza la entrada si la clave ya existe.
  Future<void> writeYears(String key, CachedMxYearsEntity entry);

  Future<CachedMxYearEntity?> readYear(String key);

  Future<void> writeYear(String key, CachedMxYearEntity entry);
}
