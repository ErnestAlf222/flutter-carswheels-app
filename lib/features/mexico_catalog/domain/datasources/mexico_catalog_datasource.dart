import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_year_catalog_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_year_source_entity.dart';

/// Origen en red del catálogo de México.
abstract class MexicoCatalogDatasource {
  /// Años ofrecidos con su recurso, del más reciente al más antiguo.
  Future<List<MxYearSourceEntity>> fetchYearSources();

  /// Todas las filas de un año, ya limpias.
  Future<MxYearCatalogEntity> fetchYear(MxYearSourceEntity source);
}
