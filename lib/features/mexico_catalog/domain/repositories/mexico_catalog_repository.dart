import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_year_catalog_entity.dart';

/// Acceso al catálogo de México por año.
abstract class MexicoCatalogRepository {
  /// Años disponibles, del más reciente al más antiguo.
  Future<List<int>> fetchYears();

  /// Filas limpias de un año; el filtrado por marca y grupo se hace en memoria.
  Future<MxYearCatalogEntity> fetchYear(int year);
}
