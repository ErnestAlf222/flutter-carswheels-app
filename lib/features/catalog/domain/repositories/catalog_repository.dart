import 'package:cars_wheels_app/features/catalog/domain/entities/brand_entity.dart';
import 'package:cars_wheels_app/features/catalog/domain/entities/model_entity.dart';

/// Acceso al catálogo de años y marcas.
abstract class CatalogRepository {
  Future<List<int>> fetchYears();

  Future<List<BrandEntity>> fetchBrands(int year);

  Future<List<ModelEntity>> fetchModels(int year, String brand);
}
