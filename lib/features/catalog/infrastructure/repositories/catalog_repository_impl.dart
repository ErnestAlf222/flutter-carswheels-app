import 'package:cars_wheels_app/features/catalog/domain/datasources/catalog_datasource.dart';
import 'package:cars_wheels_app/features/catalog/domain/entities/brand_entity.dart';
import 'package:cars_wheels_app/features/catalog/domain/repositories/catalog_repository.dart';

/// Repositorio del catálogo sobre un CatalogDatasource.
class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(this._datasource);

  final CatalogDatasource _datasource;

  @override
  Future<List<int>> fetchYears() => _datasource.fetchYears();

  @override
  Future<List<BrandEntity>> fetchBrands(int year) =>
      _datasource.fetchBrands(year);
}
