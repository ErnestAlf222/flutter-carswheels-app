import 'package:cars_wheels_app/features/catalog/domain/entities/brand_entity.dart';

/// Acceso al catálogo de años y marcas.
abstract class CatalogRepository {
  Future<List<int>> fetchYears();

  Future<List<BrandEntity>> fetchBrands(int year);
}
