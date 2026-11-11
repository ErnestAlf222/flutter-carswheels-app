import 'package:cars_wheels_app/features/catalog/domain/entities/brand_entity.dart';
import 'package:cars_wheels_app/features/catalog/domain/entities/model_entity.dart';

/// Fuente de datos del catálogo.
abstract class CatalogDatasource {
  Future<List<int>> fetchYears();

  Future<List<BrandEntity>> fetchBrands(int year);

  Future<List<ModelEntity>> fetchModels(int year, String brand);
}
